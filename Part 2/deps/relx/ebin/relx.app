{application,relx,
             [{description,"Release assembler for Erlang/OTP Releases"},
              {vsn,"git"},
              {modules, ['relx','rlx_app_info','rlx_assemble','rlx_config','rlx_file_utils','rlx_log','rlx_overlay','rlx_release','rlx_relup','rlx_resolve','rlx_state','rlx_string','rlx_tar','rlx_util']},
              {registered,[]},
              {applications,[kernel,stdlib,bbmustache]},
              {licenses,["Apache-2.0"]},
              {links,[{"Github","https://github.com/erlware/relx"}]}]}.
