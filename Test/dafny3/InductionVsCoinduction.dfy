// A definition of a co-inductive datatype Stream, whose values are possibly
// infinite lists.
codatatype Stream<T> = SNil | SCons(head: T, tail: Stream<T>);

/*
  A function that returns a stream consisting of all integers upwards of n.
  The self-call sits in a productive position and is therefore not subject to
  termination checks.  The Dafny compiler turns this co-recursive call into a
  lazily evaluated call, evaluated at the time during the program execution
  when the SCons is destructed (if ever).
*/

function Up(n: int): Stream<int>
{
  SCons(n, Up(n+1))
}

/*
  A function that returns a stream consisting of all multiples
  of 5 upwards of n.  Note that the first self-call sits in a
  productive position and is thus co-recursive.  The second self-call
  is not in a productive position and therefore it is subject to
  termination checking; in particular, each recursive call must
  decrease the specific variant function.
 */

function FivesUp(n: int): Stream<int>
  decreases (n + 4) / 5 * 5 - n;
{
  if n % 5 == 0 then SCons(n, FivesUp(n+1))
  else FivesUp(n+1)
}

// A co-predicate that holds for those integer streams where every value is greater than 0.
copredicate Pos(s: Stream<int>)
{
  match s
  case SNil => true
  case SCons(x, rest) => x > 0 && Pos(rest)
}

// SAppend looks almost exactly like Append, but cannot have 'decreases'
// clause, as it is possible it will never terminate.
function SAppend(xs: Stream, ys: Stream): Stream
{
  match xs
  case SNil => ys
  case SCons(x, rest) => SCons(x, SAppend(rest, ys))
}

/*
  Example: associativity of append on streams.

  The first method proves that append is associative when we consider first
  \S{k} elements of the resulting streams.  Equality is treated as any other
  recursive co-predicate, and has it k-th unfolding denoted as ==#[k].

  The second method invokes the first one for all ks, which lets us prove the
  assertion (included for clarity only).  The assertion implies the
  postcondition (by (F_=)).  Interestingly, in the SNil case in the first
  method, we actually prove ==, but by (F_=) applied in the opposite direction
  we also get ==#[k].
*/

ghost method {:induction false} SAppendIsAssociativeK(k:nat, a:Stream, b:Stream, c:Stream)
  ensures SAppend(SAppend(a, b), c) ==#[k] SAppend(a, SAppend(b, c));
  decreases k;
{
  match (a) {
  case SNil =>
  case SCons(h, t) => if (k > 0) { SAppendIsAssociativeK(k - 1, t, b, c); }
  }
}

ghost method SAppendIsAssociative(a:Stream, b:Stream, c:Stream)
  ensures SAppend(SAppend(a, b), c) == SAppend(a, SAppend(b, c));
{
  parallel (k:nat) { SAppendIsAssociativeK(k, a, b, c); }
  // assert for clarity only, postcondition follows directly from it
  assert (forall k:nat :: SAppend(SAppend(a, b), c) ==#[k] SAppend(a, SAppend(b, c)));
}

// Equivalent proof using the comethod syntax.
comethod {:induction false} SAppendIsAssociativeC(a:Stream, b:Stream, c:Stream)
  ensures SAppend(SAppend(a, b), c) == SAppend(a, SAppend(b, c));
{
  match (a) {
  case SNil =>
  case SCons(h, t) => SAppendIsAssociativeC(t, b, c);
  }
}

// In fact the proof can be fully automatic.
comethod SAppendIsAssociative_Auto(a:Stream, b:Stream, c:Stream)
  ensures SAppend(SAppend(a, b), c) == SAppend(a, SAppend(b, c));
{
}

comethod {:induction false} UpPos(n:int)
  requires n > 0;
  ensures Pos(Up(n));
{
  UpPos(n+1);
}

comethod UpPos_Auto(n:int)
  requires n > 0;
  ensures Pos(Up(n));
{
}

// This does induction and coinduction in the same proof.
comethod {:induction false} FivesUpPos(n:int)
  requires n > 0;
  ensures Pos(FivesUp(n));
  decreases (n + 4) / 5 * 5 - n;
{
  if (n % 5 == 0) {
    FivesUpPos#[_k - 1](n + 1);
  } else {
    FivesUpPos#[_k](n + 1);
  }
}

// Again, Dafny can just employ induction tactic and do it automatically.
// The only hint required is the decrease clause.
comethod FivesUpPos_Auto(n:int)
  requires n > 0;
  ensures Pos(FivesUp(n));
  decreases (n + 4) / 5 * 5 - n;
{
}

