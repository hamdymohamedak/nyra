//! Optional Rust runtime symbols (staticlib/cdylib) for experiments and FFI tests.
//!
//! The `nyra` CLI links the **C modular runtime** under `stdlib/rt/` by default — not this crate.
//! Production `spawn { }` uses `spawn_capture` from `stdlib/rt/rt_spawn.c`.

use std::collections::VecDeque;
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::{Condvar, Mutex};
use std::thread;

static NEXT_THREAD: AtomicI32 = AtomicI32::new(1);
static PENDING: Mutex<VecDeque<i32>> = Mutex::new(VecDeque::new());
static RUNNING: AtomicI32 = AtomicI32::new(0);

/// Poll a future handle (MVP: pops from pending queue).
#[no_mangle]
pub extern "C" fn async_await(handle: i32) -> i32 {
    let _ = handle;
    loop {
        if let Ok(mut q) = PENDING.lock() {
            if let Some(v) = q.pop_front() {
                return v;
            }
        }
        thread::yield_now();
    }
}

/// Schedule async work (stores result for await).
#[no_mangle]
pub extern "C" fn async_run(result: i32) -> i32 {
    if let Ok(mut q) = PENDING.lock() {
        q.push_back(result);
    }
    RUNNING.fetch_add(1, Ordering::Relaxed);
    result
}

/// Spawn a native thread; returns thread id (MVP).
#[no_mangle]
pub extern "C" fn spawn() -> i32 {
    thread::spawn(|| {});
    NEXT_THREAD.fetch_add(1, Ordering::Relaxed)
}

pub struct ChannelInner {
    queue: Mutex<Vec<i32>>,
    notify: Condvar,
}

#[no_mangle]
pub extern "C" fn channel_new() -> *mut ChannelInner {
    Box::into_raw(Box::new(ChannelInner {
        queue: Mutex::new(Vec::new()),
        notify: Condvar::new(),
    }))
}

/// Send a value on a channel created with [`channel_new`].
///
/// # Safety
/// `ch` must be a valid pointer returned by `channel_new`, or null.
#[no_mangle]
pub unsafe extern "C" fn channel_send(ch: *mut ChannelInner, value: i32) {
    if ch.is_null() {
        return;
    }
    let ch = &*ch;
    if let Ok(mut q) = ch.queue.lock() {
        q.push(value);
        ch.notify.notify_one();
    }
}

/// Receive a value from a channel created with [`channel_new`].
///
/// # Safety
/// `ch` must be a valid pointer returned by `channel_new`, or null.
#[no_mangle]
pub unsafe extern "C" fn channel_recv(ch: *mut ChannelInner) -> i32 {
    if ch.is_null() {
        return 0;
    }
    let ch = &*ch;
    let mut q = ch.queue.lock().expect("channel mutex");
    while q.is_empty() {
        q = ch.notify.wait(q).expect("channel condvar");
    }
    q.pop().unwrap_or(0)
}

/// Release a channel allocated with channel_new.
///
/// # Safety
/// `ch` must be a valid pointer returned by `channel_new`, or null.
#[no_mangle]
pub unsafe extern "C" fn channel_free(ch: *mut ChannelInner) {
    if ch.is_null() {
        return;
    }
    drop(Box::from_raw(ch));
}
