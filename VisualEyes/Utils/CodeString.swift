//
//  CodeString.swift
//  algoGameTest
//
//  Created by Danny Chew on 3/30/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import Foundation

class CodeString {
    /*
     BFS (G, s)
         let Q be queue.
         Q.enqueue( s )
         mark s as visited.
         while ( Q is not empty)
             v  =  Q.dequeue( )
             for all neighbours w of v in Graph G
                 if w is not visited
                     Q.enqueue( w )
                     mark w as visited.
    */
    static func bfs() -> [String] {
        return [
            "BFS (G, s)",
            "   let Q be queue.",
            "   Q.enqueue(s)",
            "   mark s as visited.",
            "   while ( Q is not empty)",
            "       v = Q.dequeue( )",
            "       for all neighbours w of v in Graph G",
            "           if w is not visited ",
            "               Q.enqueue( w )",
            "               mark w as visited."
        ]
    }
    
    /*
     lexi
     1  procedure DFS(G,v):
     2      label v as discovered
     3      for all edges from v to w in G.adjacentEdges(v) do
     4          if vertex w is not labeled as discovered then
     5              recursively call DFS(G,w)
     */
    static func dfslexi() -> [String] {
        return [
            "DFS(G,v)",
            "   label v as discovered",
            "   Q.enqueue(s)",
            "   for all edges from v to w in G.adjacentEdges(v):",
            "       if vertex w is not labeled as discovered:",
            "           DFS(G,w)"
        ]
    }
    /* Non-lexi
     1  procedure DFS-iterative(G,v):
     2      let S be a stack
     3      S.push(v)
     4      while S is not empty
     5          v = S.pop()
     6          if v is not labeled as discovered:
     7              label v as discovered
     8              for all edges from v to w in G.adjacentEdges(v) do
     9                  S.push(w)
     */
    static func dfsnonlexi() -> [String] {
        return [
            "DFS(G,v)",
            "   let S be a stack",
            "   S.push(v)",
            "   while S is not empty:",
            "       v = S.pop()",
            "       if v is not labeled as discovered:",
            "       label v as discovered",
            "       for all edges from v to w in G.adjacentEdges(v):",
            "           S.push(w)"
        ]
    }
    /*
     1  Dijkstra(Graph, source):
     2
     3      create vertex set Q
     4
     5      for each vertex v in Graph:             // Initialization
     6          dist[v] ← INFINITY                  // Unknown distance from source to v
     7          prev[v] ← UNDEFINED                 // Previous node in optimal path from source
     8          add v to Q                          // All nodes initially in Q (unvisited nodes)
     9
     10      dist[source] ← 0                        // Distance from source to source
     11
     12      while Q is not empty:
     13          u ← vertex in Q with min dist[u]    // Node with the least distance
     14                                                      // will be selected first
     15          remove u from Q
     16
     17          for each neighbor v of u:           // where v is still in Q.
     18              alt ← dist[u] + length(u, v)
     19              if alt < dist[v]:               // A shorter path to v has been found
     20                  dist[v] ← alt
     21                  prev[v] ← u
     22
     23      return dist[], prev[]
    */
    static func dijkstra() -> [String] {
        return [
            "Dijkstra(G, s)",
            "   create vertex set Q",
            "   for each vertex v in Graph:",
            "       dist[v] ← INFINITY",
            "       prev[v] ← UNDEFINED",
            "       add v to Q",
            "   dist[source] ← 0 ",
            "       while Q is not empty:",
            "           u ← vertex in Q with min dist[u]",
            "           remove u from Q",
            "       for each neighbor v of u:",
            "           alt ← dist[u] + length(u, v)",
            "           if alt < dist[v]:",
            "               dist[v] ← alt",
            "               prev[v] ← u",
            "           alt ← dist[u] + length(u, v)",
            "   return dist[], prev[]",
        ]
    }
    
    /*
     InsertionSort(A)
         i ← 1
         while i < length(A)
             j ← i
             while j > 0 and A[j-1] > A[j]
                 swap A[j] and A[j-1]
                 j ← j - 1
             end while
             i ← i + 1
         end while
    */
    static func insertionSort() -> [String] {
          return [
            "InsertionSort(A)",
            "   i ← 1",
            "   while i < length(A)",
            "       j ← i",
            "       while j > 0 and A[j-1] > A[j]",
            "           swap A[j] and A[j-1]",
            "           j ← j - 1",
            "       end while",
            "       i ← i + 1",
            "   end while",
        ]
    }
    
    /*
     Quicksort(A, lo, hi):
         if lo < hi then
             p := partition(A, lo, hi)
             quicksort(A, lo, p)
             quicksort(A, p + 1, hi)
     
     Partition(A, lo, hi):
        pivot := A[hi]
         i := lo - 1
         for j := lo to hi - 1 do
            if A[j] < pivot then
                i := i + 1
                swap A[i] with A[j]
        swap A[i + 1] with A[hi]
         return i + 1
    */
    static func quickSort() -> [String] {
        return [
            "Quicksort(A, lo, hi):",
            "   if lo < hi:",
            "       p := partition(A, lo, hi)",
            "       quicksort(A, lo, p)",
            "       quicksort(A, p + 1, hi)\n",
            "Partition(A, lo, hi)",
            "   pivot := A[hi]",
            "   i := lo - 1",
            "   for j := lo to hi - 1 :",
            "       if A[j] < pivot :",
            "           i := i + 1",
            "           swap A[i] with A[j]",
            "   swap A[i + 1] with A[hi]",
            "   return i + 1"
        ]
    }
    
    static func trace1() -> [String] {
        return [
        "for i in 1 ..< n+1 {",
        "   var j = n",
        "   var str = \"\"",
        "   while (j > i) {",
        "       str += \" \"",
        "       j -= 1",
        "   }",
        "   while (j >= 0) {",
        "       str += \"*\"",
        "       j -= 1",
        "   }",
        "   print(str)",
        "}"
        ]
    }
    
    static func trace2() -> [String] {
        return [
            "for i in 1 to n+1:",
            "   var str = \"\"",
            "   for j in 1 to (n - i) :",
            "       str += \" \"",

            "   for _ in 1 to i :",
            "       str += \"* \"",

            "   print(str)",
            "k = 0",
            "for i in n to 0:",
            "   var str = \"\"",
            "   for j in 1 to k - 1 :",
            "       str += \" \"",
            "   k += 1",
            "   for j in 1 to i :",
            "       str += \"* \"",
            "   print(str)",
        ]
    }
    

}
