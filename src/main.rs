#![feature(slice_split_once, never_type, peekable_next_if_map)]
#![no_main]

use std::{env, io, fs, slice};
use std::process::Command;
use std::ffi::{OsStr, CStr, c_char, c_int};
use std::os::unix::{ffi::OsStrExt, process::CommandExt};

fn run(file: &[u8]) -> ! {
    let mut iter = file.trim_ascii_end().split(|&ch| ch == b'\n').peekable();
    iter.next(); // shebang line
    let mut cmd = Command::new(OsStr::from_bytes(iter.next().unwrap()));
    
    while let Some((key, val)) = iter.next_if_map(|l| l.split_once(|&ch| ch == b'=').ok_or(l)) {
        cmd.env(OsStr::from_bytes(key), OsStr::from_bytes(val));
    }
    cmd.args(iter.map(OsStr::from_bytes));
    panic!("{}", cmd.exec())
}

#[unsafe(no_mangle)]
unsafe extern "C" fn main(argc: c_int, argv: *const *const c_char) -> c_int {
    // Safety: if this is UB, then every C program is probably UB
    let path = unsafe {
        let argv = slice::from_raw_parts(argv, argc as usize);
        CStr::from_ptr(argv[1])
    };
    let path = OsStr::from_bytes(path.to_bytes());
    let file = fs::read(path).unwrap();
    run(&file)
}
