The statements below are somewhat outdated. Please read the short reference in doc/ShortReference for an introduction. Theoretical background about the implementation can be found in:

H. Dankowicz, F. Schilder; An extended continuation problem for bifurcation analysis in the presence of constraints, ASME Journal of Computational and Nonlinear Dynamics, Vol. 6, No. 3, 031003, 2011.


Using COCO:

- uncompress the package
- start Matlab
- in Matlab change to coco/toolboxes
- execute startup.m
- change to coco/examples and run the demos

To simplify using coco you might want to execute startup.m whenever Matlab starts. Please see the Matlab documentation for how to do this.

The text below is outdated. There will soon be a paper on the mathematical concepts of the core and we will update the documentation in the M-files of coco.

#####################################################################
This file contains some very basic documentation of ideas fundamental to this package. The ultimate source of reference is still the source code though.



1. The philosophy of the data structure opts
--------------------------------------------

The basic objectives behind the opts structure are to make it easy to replace parts of an algorithm, to avoid the use of global variables or long argument lists and to store the full state of the continuation algorithm in an organised way. For example, it should be possible to replace Newton's method with another algorithm, or the code for 1D continuation with a code for 2D continuation. Also, the user should be able to set certain constants influencing algorithms in a fairly simple way.

The dependencies within individual parts of a continuation code have the form of a graph. This graph may be quite deep and may contain loops (it is not a tree). We represent such a graph as a dictionary, that is, a table with two columns, a class name and a set of values. This table is encoded as a structure and the principal form of access is

  val = opts.class_name.property_name

Now, a class like 'cont' may contain a property named 'corrector', which specifies the corrector to use by the continuation method. It would access functions and properties defined by this corrector with

  corrector = opts.cont.corrector
  opts = opts.(corrector).some_function(opts, ...)

This is similar to pointers and one can exchange the corrector by assigning a non-default value to the property 'corrector' of the class 'cont'. This way it is possible to represent arbitrary graphs with a flat data structure.

You should aim at making it possible to replace algorithms in a transparent way as much as possible. You should pass and return the opts structure in/from any algorithm. Use function definitions like

  function [opts, varargout] = some_function(opts, varargin)

This somewhat strange syntax of having an input and output argument with the same name allows Matlab to optimise access to the structure opts (that is, to avoid any unnecessary copying).



2. The concept of sub-toolboxing
--------------------------------

The idea of sub-toolboxing is to make it possible that any toolbox for some continuation problem can be used as a building block for other toolboxes. Take, as a simple example, the continuation of homoclinic orbits. The classic way to attack this problem is to construct a BVP that contains the equations for the fixed point and its invariant manifolds in the boundary conditions. A more natural way seems to be to combine two toolboxes, one for fixed point continuation with another one for solutions of boundary value problems. These two toolboxes would become sub-toolboxes of a homoclinic orbit toolbox, which in turn is a sub-toolbox for the continuation code.

Toolboxes like MPBVP should be designed keeping this in mind. They should provide a full set of interface functions for constructing and manipulating equations and for accessing all parts of the solution in a well-defined way.

The ideal toolbox does a specific well-defined job and can be replaced by any other toolbox offereing the same interface.

At the moment our toolboxes do not strictly follow this idea as the entry functions with names defined as

  func_name = sprintf('%s_%s2%s', TOOLBOX, FROM_ST, TO_ST)

call Newton's method COCO explicitly. Instead, they should only construct an algorithm in functional form and an initial solution and then return to COCO. This will be one of the more important changes to this package; see the next section for more details.



3. Changes planned in the future
--------------------------------

There are several changes we want to make, which are due to design limitations that we discovered during testing.

We plan to reorganise the finite state machine for the continuation code. The main goal is to split it properly according to functionality. The corrector is already a separate toolbox. Similarly, we will have a rather abstract continuation code and a toolbox representing a manifold. The latter toolbox will become responsible for constructing an apropriate data structure, the construction of extended systems, the prediction and mesh-adaptation (of the mesh of the family of solutions, not the collocation points). The continuation code will be rearranged to work with srbitrary-dimensional families of solutions.

Another major addition is to enable additional constraints and test functions. This is quite complicated and may strongly influence the communication with other toolboxes. As yet it is not clear how we are going to implement this important feature. We aim at making it possible to add constraints and allow the continuation of higher co-dimension curves/families. We also aim at making this independent of the dimension of the family of solutions.

There are a number of other changes that may influence other toolboxes. Please see the file toolbox/todo.txt for a complete list of open problems.
