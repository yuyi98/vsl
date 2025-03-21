module mpi

import vsl.errors
import math.complex

fn C.MPI_Initialized(flag &int) int
fn C.MPI_Init(argc int, argv &charptr) int
fn C.MPI_Init_thread(argc int, argv &charptr, required int, provided &int) int

type MPI_Comm = int
type MPI_Datatype = voidptr
type MPI_Group = voidptr
type MPI_Status = voidptr
type MPI_Op = voidptr

fn C.MPI_Comm_rank(comm MPI_Comm, rank &int) int
fn C.MPI_Comm_size(comm MPI_Comm, size &int) int
fn C.MPI_Comm_group(comm MPI_Comm, group &MPI_Group) int
fn C.MPI_Group_incl(group MPI_Group, n int, ranks &int, newgroup &MPI_Group) int
fn C.MPI_Comm_create(comm MPI_Comm, group MPI_Group, newcomm &MPI_Comm) int

fn C.MPI_Abort(comm MPI_Comm, errorcode int) int
fn C.MPI_Finalize() int
fn C.MPI_Finalized(flag &int) int
fn C.MPI_Barrier(comm MPI_Comm) int
fn C.MPI_Bcast(buffer &voidptr, count int, datatype MPI_Datatype, root int, comm MPI_Comm) int
fn C.MPI_Reduce(sendbuf &voidptr, recvbuf &voidptr, count int, datatype MPI_Datatype, op MPI_Op, root int, comm MPI_Comm) int
fn C.MPI_Allreduce(sendbuf &voidptr, recvbuf &voidptr, count int, datatype MPI_Datatype, op MPI_Op, comm MPI_Comm) int
fn C.MPI_Send(buf &voidptr, count int, datatype MPI_Datatype, dest int, tag int, comm MPI_Comm) int
fn C.MPI_Recv(buf &voidptr, count int, datatype MPI_Datatype, source int, tag int, comm MPI_Comm, status &MPI_Status) int

// is_on tells whether MPI is on or not
//  note: this returns true even after stop
pub fn is_on() bool {
	flag := 0
	C.MPI_Initialized(&flag)
	return flag != 0
}

// start initialises MPI
pub fn start() ? {
	C.MPI_Init(0, unsafe { nil })
}

// start_thread_safe initialises MPI in a thread safe way
pub fn start_thread_safe() ? {
	r := 0
	C.MPI_Init_thread(0, unsafe { nil }, C.MPI_THREAD_MULTIPLE, &r)
	if r != C.MPI_THREAD_MULTIPLE {
		return errors.error("MPI_THREAD_MULTIPLE can't be set: got $r", .efailed)
	}
}

// stop finalises MPI
pub fn stop() {
	C.MPI_Finalize()
}

// world_rank returns the processor rank/ID within the World Communicator
pub fn world_rank() int {
	r := 0
	C.MPI_Comm_rank(C.MPI_COMM_WORLD, &r)
	return r
}

// world_size returns the number of processors in the World Communicator
pub fn world_size() int {
	r := 0
	C.MPI_Comm_size(C.MPI_COMM_WORLD, &r)
	return r
}

// Communicator holds the World Communicator or a subset Communicator
pub struct Communicator {
mut:
	comm  MPI_Comm
	group MPI_Group
}

// new_communicator creates a new communicator or returns the World Communicator
//   ranks -- World indices of processors in this Communicator.
//            use nil or empty to get the World Communicator
pub fn new_communicator(ranks []int) ?&Communicator {
	mut o := &Communicator{
		comm: MPI_Comm(C.MPI_COMM_WORLD)
		group: unsafe { nil }
	}
	if ranks.len == 0 {
		C.MPI_Comm_group(C.MPI_COMM_WORLD, &o.group)
		return o
	}

	rs := ranks.clone()
	r := unsafe { &rs[0] }
	wgroup := MPI_Group(0)
	C.MPI_Comm_group(C.MPI_COMM_WORLD, &wgroup)
	C.MPI_Group_incl(wgroup, ranks.len, r, &o.group)
	C.MPI_Comm_create(C.MPI_COMM_WORLD, o.group, &o.comm)
	return o
}

// rank returns the processor rank/ID
pub fn (o &Communicator) rank() int {
	r := 0
	C.MPI_Comm_rank(o.comm, &r)
	return r
}

// size returns the number of processors
pub fn (o &Communicator) size() int {
	r := 0
	C.MPI_Comm_size(o.comm, &r)
	return r
}

// abort aborts MPI
pub fn (o &Communicator) abort() {
	C.MPI_Abort(o.comm, 0)
}

// barrier forces synchronisation
pub fn (o &Communicator) barrier() {
	C.MPI_Barrier(o.comm)
}

// bcast_from_root broadcasts slice from root (Rank == 0) to all other processors
pub fn (o &Communicator) bcast_from_root(x []f64) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_DOUBLE, 0, o.comm)
}

// bcast_from_root_c broadcasts slice from root (Rank == 0) to all other processors (complex version)
pub fn (o &Communicator) bcast_from_root_c(x []complex.Complex) {
	C.MPI_Bcast(unsafe { &x[0] }, x.len, C.MPI_DOUBLE, 0, o.comm)
}

// reduce_sum sums all values in 'orig' to 'dest' in root (Rank == 0) processor
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum(mut dest []f64, orig []f64) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE, C.MPI_SUM,
		0, o.comm)
}

// reduce_sum_c sums all values in 'orig' to 'dest' in root (Rank == 0) processor (complex version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) reduce_sum_c(mut dest []complex.Complex, orig []complex.Complex) {
	C.MPI_Reduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE, C.MPI_SUM,
		0, o.comm)
}

// all_reduce_sum combines all values from orig into dest summing values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_SUM, o.comm)
}

// all_reduce_sum_c combines all values from orig into dest summing values (complex version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_sum_c(mut dest []complex.Complex, orig []complex.Complex) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_SUM, o.comm)
}

// all_reduce_min combines all values from orig into dest picking minimum values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_MIN, o.comm)
}

// all_reduce_max combines all values from orig into dest picking minimum values
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max(mut dest []f64, orig []f64) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_DOUBLE,
		C.MPI_MAX, o.comm)
}

// all_reduce_min_i combines all values from orig into dest picking minimum values (integer version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_min_i(mut dest []int, orig []int) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MIN,
		o.comm)
}

// all_reduce_max_i combines all values from orig into dest picking minimum values (integer version)
//   note (important): orig and dest must be different slices
pub fn (o &Communicator) all_reduce_max_i(mut dest []int, orig []int) {
	C.MPI_Allreduce(unsafe { &orig[0] }, unsafe { &dest[0] }, orig.len, C.MPI_INT, C.MPI_MAX,
		o.comm)
}

// send sends values to processor toID
pub fn (o &Communicator) send(vals []f64, to_id int) {
	C.MPI_Send(unsafe { &vals[0] }, vals.len, C.MPI_DOUBLE, to_id, 0, o.comm)
}

// recv receives values from processor fromId
pub fn (o &Communicator) recv(vals []f64, from_id int) {
	C.MPI_Recv(unsafe { &vals[0] }, vals.len, C.MPI_DOUBLE, from_id, 0, o.comm, unsafe { nil })
}

// send_c sends values to processor toID (complex version)
pub fn (o &Communicator) send_c(vals []complex.Complex, to_id int) {
	C.MPI_Send(unsafe { &vals[0] }, vals.len, C.MPI_DOUBLE, to_id, 0, o.comm)
}

// recv_c receives values from processor fromId (complex version)
pub fn (o &Communicator) recv_c(vals []complex.Complex, from_id int) {
	C.MPI_Recv(unsafe { &vals[0] }, vals.len, C.MPI_DOUBLE, from_id, 0, o.comm, unsafe { nil })
}

// send_i sends values to processor toID (integer version)
pub fn (o &Communicator) send_i(vals []int, to_id int) {
	C.MPI_Send(unsafe { &vals[0] }, vals.len, C.MPI_INT, to_id, 0, o.comm)
}

// recv_i receives values from processor fromId (integer version)
pub fn (o &Communicator) recv_i(vals []int, from_id int) {
	C.MPI_Recv(unsafe { &vals[0] }, vals.len, C.MPI_INT, from_id, 0, o.comm, unsafe { nil })
}

// send_one sends one value to processor toID
pub fn (o &Communicator) send_one(val f64, to_id int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, to_id, 0, o.comm)
}

// recv_one receives one value from processor fromId
pub fn (o &Communicator) recv_one(from_id int) f64 {
	vals := [0.0]
	C.MPI_Recv(unsafe { &vals[0] }, 1, C.MPI_DOUBLE, from_id, 0, o.comm, unsafe { nil })
	return vals[0]
}

// send_one_i sends one value to processor toID (integer version)
pub fn (o &Communicator) send_one_i(val int, to_id int) {
	vals := [val]
	C.MPI_Send(unsafe { &vals[0] }, 1, C.MPI_INT, to_id, 0, o.comm)
}

// recv_one_i receives one value from processor fromId (integer version)
pub fn (o &Communicator) recv_one_i(from_id int) int {
	vals := [0]
	C.MPI_Recv(unsafe { &vals[0] }, 1, C.MPI_INT, from_id, 0, o.comm, unsafe { nil })
	return vals[0]
}
