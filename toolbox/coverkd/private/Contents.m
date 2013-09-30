
%Private functions of COCO.
%
%COCO options structure:

%
%Finite state machine (continuation method):










%
%Tangent predictor:



%
%Extended system:


%
%Bifurcation diagram:




%
%Saving data:


%
%Screen output:




%
%Default functions and event handlers:










%   bddat_append          - Add a point at the end of the point list.
%   bddat_init            - Initialise bifurcation diagram.
%   bddat_insert          - Insert a point into the bifurcation diagram.
%   bddat_prepend         - Add a point at the beginning of the point list.
%   cover1d_default_print - COCO_DEFAULT_PRINT  Default implementation for printing additional data.
%   cover1d_set_defaults  - COCO_SET_DEFAULTS  Initialise COCO options for continuation.
%   fsm_run               - COCO_CONT  Entry point to continuation method.
%   fsm_step              - COCO_CONT_STEP  Dispatch call to current state in finite-state machine.
%   print_data            - COCO_PRINT_DATA  Save data and print point information to screen.
%   print_headline        - COCO_PRINT_HEADLINE  Print headline for point information.
%   save_full             - CONT_SAVE_FULL  Save restart data for labelled solution.
%   save_reduced          - CONT_SAVE_REDUCED  Save reduced amount of data for labelled solution.
%   state_check_solution  - Check if new solution is acceptable.
%   state_compute_events  - Locate events in current simplex.
%   state_correct         - Execute correction steps.
%   state_handle_boundary - Handle 'boundary event.'
%   state_handle_events   - Handle events in current simplex.
%   state_init            - Initialise finite-state machine.
%   state_insert_point    - Insert point into bifurcation diagram.
%   state_predict         - Compute a new predicted value.
%   state_refine_step     - Refine continuation step size.
%   state_update          - Send update message to all toolboxes.
%   tpred_init            - Initialise tangent predictor.
%   tpred_predict         - Perform a prediction step.
%   tpred_update          - Update tangent predictor.
%   xfunc_DFDX            - Evaluate Jacobian of extended system at UP=[U;P].
%   xfunc_F               - Evaluate extended system at UP=[U;P].
