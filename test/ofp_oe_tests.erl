-module(ofp_oe_tests).

-include_lib("eunit/include/eunit.hrl").

-include("include/of_protocol.hrl").
-include("include/ofp_v4.hrl").

optical_transport_port_desc_request_test() ->
    Msg = #ofp_message{version = 4,
                       type    = multipart_request,
                       xid     = 0,
                       body    = #ofp_experimenter_request{
                                    experimenter = ?INFOBLOX_EXPERIMENTER,
                                    exp_type     = port_desc}},
    {ok,Enc} = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg).

optical_transport_port_desc_reply_test() ->
    V = [#ofp_port_optical_transport_layer_entry{
            layer_class = port,
            signal_type = otsn,
            adaptation  = ots_oms},
         #ofp_port_optical_transport_layer_entry{
            layer_class = och,
            signal_type = fix_grid,
            adaptation  = oduk_oduij}],
    F = [#ofp_port_optical_transport_application_code{
            feature_type    = opt_interface_class,
            oic_type        = proprietary,
            app_code        = <<"arbitrary">>},
         #ofp_port_optical_transport_layer_stack{
            feature_type    = layer_stack,
            value           = V}],
    Pr = [#ofp_port_desc_prop_optical_transport {
            type                = optical_transport,
            port_signal_type    = otsn,
            reserved            = 0,
            features            = F}],
    Data = [#ofp_port_v6{
               port_no     = 1,
               hw_addr     = <<8,0,39,255,136,50>>,
               name        = <<"Port1">>,
               config      = [],
               state       = [live],
               properties  = Pr,
               is_optical = false}],
    Msg = #ofp_message{
             version = 4,
             type = multipart_reply,
             xid = 1,
             body = #ofp_experimenter_reply{
                       experimenter    = ?INFOBLOX_EXPERIMENTER,
                       exp_type        = port_desc,
                       data            = Data}},
    ExpectedBinary = <<
                       %% ofp_header:
                       4,                  % version
                       19,                 % type (OFPT_MULTIPART_REPLY)
                       0,116,              % length
                       0,0,0,1,            % xid
                       %% ofp_multipart_reply:
                       255,255,            % type (OFPMP_EXPERIMENTER)
                       0,0,                % flags
                       0,0,0,0,            % pad
                       %% ofp_experimenter_multipart_header:
                       0,116,135,113,      % experimenter (Infoblox)
                       0,0,0,13,           % type (OFPMP_PORT_DESC)
                       %% ofp_port:
                       0,0,0,1,            % port_no (1)
                       0,92,               % length
                       0,1,                % padding that marks non-optical port
                       8,0,39,255,136,50,  % hw_addr
                       0,0,                % pad
                       80,111,114,116, 49,0,0,0, 0,0,0,0, 0,0,0,0,
                                           % name
                       0,0,0,0,            % config
                       0,0,0,4,            % state
                       %% ofp_port_desc_prop_optical_transport:
                       0,2,                % type (OFPPDPT_OPTICAL_TRANSPORT)
                       0,52,               % length
                       1,                  % port_signal_type (OFPOTPT_OTSn)
                       0,                  % reserved
                       0,0,                % pad
                       %% ofp_port_optical_transport_application_code:
                       0,1,                % feature_type (OFPPOTFT_OPT_INTERFACE_CLASS)
                       0,20,               % length
                       128,                % oic_type (OFPOICT_PROPRIETARY)
                       97,114,98,105,116, 114,97,114,121,0, 0,0,0,0,0,
                                           % app_code
                       %% ofp_port_optical_transport_layer_stack:
                       0,2,                % feature_type (OFPPOTFT_LAYER_STACK)
                       0,24,               % length
                       0,0,0,0,            % pad
                       %% ofp_port_optical_transport_layer_entry:
                       1,                  % layer_class (OFPPOTL_PORT)
                       1,                  % signal_type (OFPOTPT_OTSn)
                       1,                  % adaptation (OFPADAPT_OTS_OMS)
                       0,0,0,0,0,          % pad
                       %% ofp_port_optical_transport_layer_entry:
                       2,                  % layer_class (OFPPOTL_OCH)
                       1,                  % signal_type (OFPOCHT_FIX_GRID)
                       6,                  % adaptation (OFPADAPT_ODUk_ODUij)
                       0,0,0,0,0           % pad
                     >>,
    {ok,Enc}      = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg),
    ?assertEqual(Enc, ExpectedBinary).

optical_transport_port_status_test() ->
    V = [#ofp_port_optical_transport_layer_entry{
            layer_class = port,
            signal_type = otsn,
            adaptation  = ots_oms},
         #ofp_port_optical_transport_layer_entry{
            layer_class = och,
            signal_type = fix_grid,
            adaptation  = oduk_oduij}],
    F = [#ofp_port_optical_transport_application_code{
            feature_type    = opt_interface_class,
            oic_type        = proprietary,
            app_code        = <<"arbitrary">>},
         #ofp_port_optical_transport_layer_stack{
            feature_type    = layer_stack,
            value           = V}],
    Pr = [#ofp_port_desc_prop_optical_transport {
            type                = optical_transport,
            port_signal_type    = otsn,
            reserved            = 0,
            features            = F}],
    P = #ofp_port_v6{
            port_no     = 1,
            hw_addr     = <<8,0,39,255,136,50>>,
            name        = <<"Port1">>,
            config      = [],
            state       = [live],
            properties  = Pr},
    Body = #ofp_port_status{
            reason = add,
            desc = P},
    Msg = #ofp_message{
             version = 4,
             type = experimenter,
             xid = 12345,
             body = #ofp_experimenter{
                       experimenter = ?INFOBLOX_EXPERIMENTER,
                       exp_type     = port_status,
                       data         = Body}},
    ExpectedBinary = <<
                       %% ofp_experimenter_header
                       %% ofp_header
                       4,                   % version
                       4,                   % type (OFPT_EXPERIMENTER)
                       0,116,               % length
                       0,0,48,57,           % xid
                       0,116,135,113,       % experimenter (Infoblox)
                       0,0,0,12,            % type (OFPT_PORT_STATUS)
                       %% ofp_port_status
                       0,                   % reason (OFPPR_ADD)
                       0,0,0, 0,0,0,0,      % pad
                       %% ofp_port
                       0,0,0,1,             % port number (1)
                       0,92,                % length
                       0,1,                 % pad
                       8,0,39, 255,136,50,  % hw_addr
                       0,0,                 % pad
                       80,111,114,116, 49,0,0,0, 0,0,0,0, 0,0,0,0,
                                            % name
                       0,0,0,0,             % config
                       0,0,0,4,             % state
                       %% ofp_port_desc_prop_optical_transport
                       0,2,                 % type (OFPPDPT_OPTICAL_TRANSPORT)
                       0,52,                % length
                       1,                   % port_signal_type
                       0,                   % reserved
                       0,0,                 % pad
                       %% ofp_port_optical_transport_feature_header
                       0,1,                 % feature_type (OFPPOTFT_OPT_INTERFACE_CLASS)
                       0,20,                % length
                       128,                 % oic_type (OFPOICT_PROPRIETARY)
                       97,114,98,105,116, 114,97,114,121,0, 0,0,0,0,0,
                                            % app_code
                       %% ofp_port_optical_transport_layer_stack:
                       0,2,                 % feature_type (OFPPOTFT_LAYER_STACK)
                       0,24,                % length
                       0,0,0,0,             % pad
                       %% ofp_port_optical_transport_layer_entry:
                       1,                   % layer_class (OFPPOTL_PORT)
                       1,                   % signal_type (OFPOTPT_OTSn)
                       1,                   % adaptation (OFPADAPT_OTS_OMS)
                       0,0,0,0,0,           % pad
                       %% ofp_port_optical_transport_layer_entry:
                       2,                   % layer_class (OFPPOTL_OCH)
                       1,                   % signal_type (OFPOCHT_FIX_GRID)
                       6,                   % adaptation (OFPADAPT_ODUk_ODUij)
                       0,0,0,0,0            % pad
                     >>,

    {ok,Enc} = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg),
    ?assertEqual(Enc,ExpectedBinary).

optical_transport_port_status_simple_test() ->
    P = #ofp_port_v6{port_no     = 1,
                     hw_addr     = <<8,0,39,255,136,50>>,
                     name        = <<"Port1">>,
                     config      = [],
                     state       = [live],
                     properties  = []},
    Body = #ofp_port_status{
              reason = add,
              desc = P},
    Msg = #ofp_message{version = 4,
                       type = experimenter,
                       xid = 12345,
                       body = #ofp_experimenter{
                                 experimenter = ?INFOBLOX_EXPERIMENTER,
                                 exp_type     = port_status,
                                 data         = Body}},
    ExpectedBinary = <<
                       %% ofp_experimenter_header
                       %% ofp_header
                       4,                   % version
                       4,                   % type (OFPT_EXPERIMENTER)
                       0,64,                % length
                       0,0,48,57,           % xid
                       0,116,135,113,       % experimenter (Infoblox)
                       0,0,0,12,            % type (OFPT_PORT_STATUS)
                       %% ofp_port_status
                       0,                   % reason (OFPPR_ADD)
                       0,0,0, 0,0,0,0,      % pad
                       %% ofp_port
                       0,0,0,1,             % port number (1)
                       0,40,                % length
                       0,1,                 % pad
                       8,0,39, 255,136,50,  % hw_addr
                       0,0,                 % pad
                       80,111,114,116, 49,0,0,0, 0,0,0,0, 0,0,0,0,
                                            % name
                       0,0,0,0,             % config
                       0,0,0,4              % state
                     >>,

    {ok,Enc} = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg),
    ?assertEqual(Enc,ExpectedBinary).

flow_mod_with_oe_fields_v1_test() ->
    MatchField1 = #ofp_field{class = openflow_basic,
                            has_mask = false,
                            name = in_port,
                            value= <<3:32>>},
    MatchField2 = #ofp_oxm_experimenter{
                     body = #ofp_field{class = openflow_basic,
                                       has_mask = false,
                                       name = och_sigtype,
                                       value = <<10:8>>},
                     experimenter = ?INFOBLOX_EXPERIMENTER},
    MatchField3 = #ofp_oxm_experimenter{
                     body = #ofp_field{class = openflow_basic,
                                       has_mask = false,
                                       name = och_sigid,
                                       value = <<0:16, (_InChannelNumber = 10):16, 0:16>>},
                     experimenter = ?INFOBLOX_EXPERIMENTER},
    Field = #ofp_field{class = openflow_basic,
                       has_mask = false,
                       name = och_sigid,
                       value = <<0:16, (_OutChannelNumber = 20):16, 0:16>>},
    SetField = #ofp_action_set_field{field = Field},
    Action1 = #ofp_action_experimenter{experimenter = ?INFOBLOX_EXPERIMENTER,
                                       data = SetField},
    Action2 = #ofp_action_output{port = 4, max_len = no_buffer},
    Instruction = #ofp_instruction_apply_actions{actions = [Action1,Action2]},
    Body=#ofp_flow_mod{
               cookie = <<0:64>>,
               cookie_mask = <<0:64>>,
               table_id = 0,
               command = add,
               idle_timeout = 0,
               hard_timeout = 0,
               priority = 1,
               buffer_id = no_buffer,
               out_port = any,
               out_group = any,
               flags = [],
               match = #ofp_match{fields = [MatchField1,
                                            MatchField2,
                                            MatchField3]},
               instructions = [Instruction]},
    Msg = #ofp_message{type = flow_mod,
                        version = 4,
                        body = Body},

    ExpectedBinary = <<
                       %% ofp_header:
                       4,                  % OFP_VERSION
                       14,                 % type (OFPT_FLOW_MOD)
                       0,144,              % length
                       0,0,0,0,            % xid
                       %% ofp_flow_mod:
                       0,0,0,0, 0,0,0,0,   % cookie
                       0,0,0,0, 0,0,0,0,   % cookie_mask
                       0,                  % table_id
                       0,                  % command
                       0,0,                % idle_timeout
                       0,0,                % hard_timeout
                       0,1,                % priority
                       255,255,255,255,    % buffer_id (OFP_NO_BUFFER)
                       255,255,255,255,    % out_port (OFPP_ANY)
                       255,255,255,255,    % out_group (OFPG_ANY)
                       0,0,                % flags
                       0,0,                % pad
                       %% ofp_match:
                       0,1,                % type (OFPMT_OXM)
                       0,43,               % length
                       %% oxm_fields:
                       %% field 1:
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       0,                  % oxm_field (OFPXMT_OFB_IN_PORT), oxm_hasmask (0)
                       4,                  % length
                       0,0,0,3,            % port number (3)
                       %% field 2:
                       255,255,            % oxm_class (OFPXMC_EXPERIMENTER)
                       0,0,                % unused
                       0,116,135,113,      % experimenter (Infoblox)
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       88,                 % oxm_field (OFPXMT_OFB_OCH_SIGTYPE), oxm_hasmask (0)
                       1,                  % length
                       10,                 % signal type
                       %% field 3:
                       255,255,            % oxm_class (OFPXMC_EXPERIMENTER)
                       0,0,                % unused
                       0,116,135,113,      % experimenter (Infoblox)
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       90,                 % oxm_field (OFPXMT_OFB_OCH_SIGID), oxm_hasmask (0)
                       6,                  % length
                       0,                  % grid
                       0,                  % cs
                       0,10,               % channel number
                       0,0,                % spectral width
                       0,0,0,0,0,          %  pad
                       %% ofp_instruction:
                       0,4,                % type (OFPIT_APPLY_ACTIONS)
                       0,48,               % length
                       0,0,0,0,            % pad
                       %% ofp_action_header:
                       %% action 1:
                       255,255,            % type (OFPAT_EXPERIMENTER)
                       0,24,               % length
                       0,116,135,113,      % experimenter (Infoblox)
                       0,25,               % type (OFPAT_SET_FIELD),
                       0,16,               % length
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       90,                 % oxm_field (OFPXMT_OFB_OCH_SIGID), oxm_hasmask (0)
                       6,                  % length
                       0,                  % grid
                       0,                  % cs
                       0,20,               % channel number
                       0,0,                % spectral width
                       0,0,                % pad
                       %% ofp_action_header:
                       %% action 2
                       0,0,                % type (OFPAT_OUTPUT)
                       0,16,               % length
                       0,0,0,4,            % port
                       255,255,            % max_len
                       0,0,0,0,0,0         % pad
                     >>,
    {ok,Enc} = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg),
    ?assertEqual(Enc, ExpectedBinary).

flow_mod_with_oe_fields_v2_test() ->
    MatchField1 = #ofp_field{class = openflow_basic,
                             has_mask = false,
                             name = in_port,
                             value= <<3:32>>},
    MatchField2 = #ofp_field{class = infoblox,
                            has_mask = false,
                            name = och_sigtype,
                            value = <<10:8>>},
    MatchField3 = #ofp_field{class = infoblox,
                             has_mask = false,
                             name = och_sigid,
                             value = <<0:16, (_InChannelNumber = 10):16, 0:16>>},
    Field = #ofp_field{class = openflow_basic,
                       has_mask = false,
                       name = och_sigid,
                       value = <<0:16, (_OutChannelNumber = 20):16, 0:16>>},
    SetField = #ofp_action_set_field{field = Field},
    Action1 = #ofp_action_experimenter{experimenter = ?INFOBLOX_EXPERIMENTER,
                                       data = SetField},
    Action2 = #ofp_action_output{port = 4, max_len = no_buffer},
    Instruction = #ofp_instruction_apply_actions{actions = [Action1,Action2]},
    Body=#ofp_flow_mod{
            cookie = <<0:64>>,
            cookie_mask = <<0:64>>,
            table_id = 0,
            command = add,
            idle_timeout = 0,
            hard_timeout = 0,
            priority = 1,
            buffer_id = no_buffer,
            out_port = any,
            out_group = any,
            flags = [],
            match = #ofp_match{fields = [MatchField1,
                                         MatchField2,
                                         MatchField3]},
            instructions = [Instruction]},
    Msg = #ofp_message{ type = flow_mod,
                        version = 4,
                        body = Body
                      },

    ExpectedBinary = <<
                       %% ofp_header:
                       4,                  % OFP_VERSION
                       14,                 % type (OFPT_FLOW_MOD)
                       0,128,              % length
                       0,0,0,0,            % xid
                       %% ofp_flow_mod:
                       0,0,0,0, 0,0,0,0,   % cookie
                       0,0,0,0, 0,0,0,0,   % cookie_mask
                       0,                  % table_id
                       0,                  % command
                       0,0,                % idle_timeout
                       0,0,                % hard_timeout
                       0,1,                % priority
                       255,255,255,255,    % buffer_id (OFP_NO_BUFFER)
                       255,255,255,255,    % out_port (OFPP_ANY)
                       255,255,255,255,    % out_group (OFPG_ANY)
                       0,0,                % flags
                       0,0,                % pad
                       %% ofp_match:
                       0,1,                % type (OFPMT_OXM)
                       0,27,               % length
                       %% oxm_fields:
                       %% field 1:
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       0,                  % oxm_field (OFPXMT_OFB_IN_PORT), oxm_hasmask (0)
                       4,                  % length
                       0,0,0,3,            % port number (3)
                       %% field 2:
                       0,8,                % oxm_class (INFOBLOX)
                       88,                 % oxm_field (OFPXMT_OFB_OCH_SIGTYPE), oxm_hasmask (0)
                       1,                  % length
                       10,                 % signal type
                       %% field 3:
                       0,8,                %% oxm_class (INFOBLOX)
                       90,                 % oxm_field (OFPXMT_OFB_OCH_SIGID), oxm_hasmask (0)
                       6,                  % length
                       0,                  % grid
                       0,                  % cs
                       0,10,               % channel number
                       0,0,                % spectral width
                       0,0,0,0,0,          %  pad
                       %% ofp_instruction:
                       0,4,                % type (OFPIT_APPLY_ACTIONS)
                       0,48,               % length
                       0,0,0,0,            % pad
                       %% ofp_action_header:
                       %% action 1:
                       255,255,            % type (OFPAT_EXPERIMENTER)
                       0,24,               % length
                       0,116,135,113,      % experimenter (Infoblox)
                       0,25,               % type (OFPAT_SET_FIELD),
                       0,16,               % length
                       128,0,              % oxm_class (OFPXMC_OPENFLOW_BASIC)
                       90,                 % oxm_field (OFPXMT_OFB_OCH_SIGID), oxm_hasmask (0)
                       6,                  % length
                       0,                  % grid
                       0,                  % cs
                       0,20,               % channel number
                       0,0,                % spectral width
                       0,0,                % pad
                       %% ofp_action_header:
                       %% action 2
                       0,0,                % type (OFPAT_OUTPUT)
                       0,16,               % length
                       0,0,0,4,            % port
                       255,255,            % max_len
                       0,0,0,0,0,0         % pad
                     >>,
    {ok,Enc} = of_protocol:encode(Msg),
    {ok,Dec,<<>>} = of_protocol:decode(Enc),
    ?assertEqual(Dec,Msg),
    ?assertEqual(ExpectedBinary, Enc).

trace() ->
    Mods = [ ofp_v4_encode, ofp_v4_deocde ],
    dbg:tracer(),
    dbg:p(all,call),
    [ dbg:tpl(Mod,[{'_',[],[{message,{return_trace}}]}]) || Mod <- Mods ].
