//
//  CwlCatchBadInstruction.m
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 2016/01/10.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#if defined(__x86_64__)

#import "CwlCatchBadInstruction.h"

// Assuming the "PRODUCT_NAME" macro is defined, this will create the name of the Swift generated header file
#define STRINGIZE_NO_EXPANSION(A) #A
#define STRINGIZE_WITH_EXPANSION(A) STRINGIZE_NO_EXPANSION(A)
#define SWIFT_INCLUDE STRINGIZE_WITH_EXPANSION(PRODUCT_NAME-Swift.h)

// Include the Swift generated header file
#import SWIFT_INCLUDE

/// A basic function that receives callbacks from mach_exc_server and relays them to the Swift implemented BadInstructionException.catch_mach_exception_raise_state.
kern_return_t catch_mach_exception_raise_state(mach_port_t exception_port, exception_type_t exception, const mach_exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, const thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt) {
    return [BadInstructionException catch_mach_exception_raise_state:exception_port exception:exception code:code codeCnt:codeCnt flavor:flavor old_state:old_state old_stateCnt:old_stateCnt new_state:new_state new_stateCnt:new_stateCnt];
}

// The mach port should be configured so that this function is never used.
kern_return_t catch_mach_exception_raise(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt) {
	assert(false);
    return KERN_FAILURE;
}

// The mach port should be configured so that this function is never used.
kern_return_t catch_mach_exception_raise_state_identity(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt) {
	assert(false);
    return KERN_FAILURE;
}

#endif
