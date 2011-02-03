class PriorityQueue {
  var N: int;  // capacity
  var n: int;  // current size
  ghost var Repr: set<object>;  // set of objects that make up the representation of a PriorityQueue

  var a: array<int>;  // private implementation of PriorityQueu

  function Valid(): bool
    reads this, Repr;
  {
    MostlyValid() &&
    (forall j :: 2 <= j && j <= n ==> a[j/2] <= a[j])
  }

  function MostlyValid(): bool
    reads this, Repr;
  {
    this in Repr && a in Repr &&
    a != null && a.Length == N+1 &&
    0 <= n && n <= N
  }

  method Init(capacity: int)
    requires 0 <= capacity;
    modifies this;
    ensures Valid() && fresh(Repr - {this});
    ensures N == capacity;
  {
    N := capacity;
    var arr := new int[N+1];
    a := arr;
    n := 0;
    Repr := {this};
    Repr := Repr + {a};
  }

  method Insert(x: int)
    requires Valid() && n < N;
    modifies this, a;
    ensures Valid() && fresh(Repr - old(Repr));
    ensures n == old(n) + 1 && N == old(N);
  {
    n := n + 1;
    a[n] := x;
    call SiftUp(n);
  }

  method SiftUp(k: int)
    requires 1 <= k && k <= n;
    requires MostlyValid();
    requires (forall j :: 2 <= j && j <= n && j != k ==> a[j/2] <= a[j]);
    requires (forall j :: 1 <= j && j <= n ==> j/2 != k);  // k is a child
    modifies a;
    ensures Valid();
  {
    var i := k;
    assert MostlyValid();
    while (1 < i)
      invariant i <= k && MostlyValid();
      invariant (forall j :: 2 <= j && j <= n && j != i ==> a[j/2] <= a[j]);
      invariant (forall j :: 1 <= j/2/2 && j/2 == i && j <= n ==> a[j/2/2] <= a[j]);
    {
      if (a[i/2] <= a[i]) {
        return;
      }
      var tmp := a[i];  a[i] := a[i/2];  a[i/2] := tmp;
      i := i / 2;
    }
  }

  method RemoveMin() returns (x: int)
    requires Valid() && 1 <= n;
    modifies this, a;
    ensures Valid() && fresh(Repr - old(Repr));
    ensures n == old(n) - 1;
  {
    x := a[1];
    a[1] := a[n];
    n := n - 1;
    call SiftDown(1);
  }

  method SiftDown(k: int)
    requires 1 <= k;
    requires MostlyValid();
    requires (forall j :: 2 <= j && j <= n && j/2 != k ==> a[j/2] <= a[j]);
    requires k == 1;
    modifies a;
    ensures Valid();
  {
    var i := k;
    while (2*i <= n)  // while i is not a leaf
      invariant 1 <= i && MostlyValid();
      invariant (forall j :: 2 <= j && j <= n && j/2 != i ==> a[j/2] <= a[j]);
      invariant (forall j :: 1 <= j/2/2 && j/2 == i && j <= n ==> a[j/2/2] <= a[j]);
    {
      var smallestChild;
      if (2*i + 1 <= n && a[2*i + 1] < a[2*i]) {
        smallestChild := 2*i + 1;
      } else {
        smallestChild := 2*i;
      }
      if (a[i] <= a[smallestChild]) {
        return;
      }
      var tmp := a[i];  a[i] := a[smallestChild];  a[smallestChild] := tmp;
      i := smallestChild;
      assert 1 <= i/2/2 ==> a[i/2/2] <= a[i];
    }
  }
}

// ---------- Alternative specifications ----------

class PriorityQueue_Alternative {
  var N: int;  // capacity
  var n: int;  // current size
  ghost var Repr: set<object>;  // set of objects that make up the representation of a PriorityQueue

  var a: array<int>;  // private implementation of PriorityQueu

  function Valid(): bool
    reads this, Repr;
  {
    MostlyValid() &&
    (forall j :: 2 <= j && j <= n ==> a[j/2] <= a[j])
  }

  function MostlyValid(): bool
    reads this, Repr;
  {
    this in Repr && a in Repr &&
    a != null && a.Length == N+1 &&
    0 <= n && n <= N
  }

  method Init(capacity: int)
    requires 0 <= capacity;
    modifies this;
    ensures Valid() && fresh(Repr - {this});
    ensures N == capacity;
  {
    N := capacity;
    var arr := new int[N+1];
    a := arr;
    n := 0;
    Repr := {this};
    Repr := Repr + {a};
  }

  method Insert(x: int)
    requires Valid() && n < N;
    modifies this, a;
    ensures Valid() && fresh(Repr - old(Repr));
    ensures n == old(n) + 1 && N == old(N);
  {
    n := n + 1;
    a[n] := x;
    call SiftUp(n);
  }

  method SiftUp(k: int)
    requires 1 <= k && k <= n;
    requires MostlyValid();
    requires (forall j :: 2 <= j && j <= n && j != k ==> a[j/2] <= a[j]);
    requires (forall j :: 1 <= j && j <= n ==> j/2 != k);  // k is a child
    modifies a;
    ensures Valid();
  {
    var i := k;
    assert MostlyValid();
    while (1 < i)
      invariant i <= k && MostlyValid();
      invariant (forall j :: 2 <= j && j <= n && j != i ==> a[j/2] <= a[j]);
      invariant (forall j :: 1 <= j/2/2 && j/2 == i && j <= n ==> a[j/2/2] <= a[j]);
    {
      if (a[i/2] <= a[i]) {
        return;
      }
      var tmp := a[i];  a[i] := a[i/2];  a[i/2] := tmp;
      i := i / 2;
    }
  }

  method RemoveMin() returns (x: int)
    requires Valid() && 1 <= n;
    modifies this, a;
    ensures Valid() && fresh(Repr - old(Repr));
    ensures n == old(n) - 1;
  {
    x := a[1];
    a[1] := a[n];
    n := n - 1;
    call SiftDown(1);
  }

  method SiftDown(k: int)
    requires 1 <= k;
    requires MostlyValid();
    requires (forall j :: 2 <= j && j <= n && j/2 != k ==> a[j/2] <= a[j]);
    requires k == 1;  // k is the root
    modifies a;
    ensures Valid();
  {
    var i := k;
    while (2*i <= n)  // while i is not a leaf
      invariant 1 <= i && MostlyValid();
      invariant (forall j :: 2 <= j && j <= n && j/2 != i ==> a[j/2] <= a[j]);
      invariant (forall j :: 1 <= j/2/2 && j/2 == i && j <= n ==> a[j/2/2] <= a[j]);
    {
      var smallestChild;
      if (2*i + 1 <= n && a[2*i + 1] < a[2*i]) {
        smallestChild := 2*i + 1;
      } else {
        smallestChild := 2*i;
      }
      if (a[i] <= a[smallestChild]) {
        return;
      }
      var tmp := a[i];  a[i] := a[smallestChild];  a[smallestChild] := tmp;
      i := smallestChild;
      assert 1 <= i/2/2 ==> a[i/2/2] <= a[i];
    }
  }
}