"""
Initializes the MYSQL object. Must be called before mysql_real_connect.
Memory allocated by mysql_init can be freed with mysql_close.
"""
function mysql_init(mysqlptr::MYSQL)
    return ccall((:mysql_init, mysql_lib),
                 Ptr{Void},
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Used to connect to database server. Returns a MYSQL handle on success and
C_NULL on failure.
"""
function mysql_real_connect(mysqlptr::MYSQL,
                            host::String,
                            user::String,
                            passwd::String,
                            db::String,
                            port::Cint,
                            unix_socket::Any,
                            client_flag::Uint64)

    reconnect_flag::Cuint = MySQL.MYSQL_OPTION.MYSQL_OPT_RECONNECT
    reconnect_option::Cuchar = 0
    retVal = MySQL.mysql_options(mysqlptr, reconnect_flag, reinterpret(Ptr{None},
                                   pointer_from_objref(reconnect_option)))
    if(retVal != 0)
        println("WARNING:::Options not set !!! The retVal is :: $retVal")
    end

    return ccall((:mysql_real_connect, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Cuint,
                  Ptr{Cuchar},
                  Uint64),
                 mysqlptr,
                 host,
                 user,
                 passwd,
                 db,
                 port,
                 unix_socket,
                 client_flag)
end

"""
Used to set options. Must be called after mysql_init and before
mysql_real_connect. Can be called multiple times to set options.
Returns non zero on error.
"""
function mysql_options(mysqlptr::MYSQL,
                       option_type::Cuint,
                       option::Ptr{None})
    return ccall((:mysql_options, mysql_lib),
                 Cint,
                 (Ptr{Cuchar},
                  Cint,
                  Ptr{Cuchar}),
                 mysqlptr,
                 option_type,
                 option)
end

"""
Close an opened MySQL connection.
"""
function mysql_close(mysqlptr::MYSQL)
    return ccall((:mysql_close, mysql_lib),
                 Void,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Returns the error number of the last API call.
"""
function mysql_errno(mysqlptr::MYSQL)
    return ccall((:mysql_errno, mysql_lib),
                 Cuint,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Returns a string of the last error message of the most recent function call.
If no error occured and empty string is returned.
"""
function mysql_error(mysqlptr::MYSQL)
    return ccall((:mysql_error, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Executes the prepared query associated with the statement handle.
"""
function mysql_stmt_execute(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_execute, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Closes the prepared statement.
"""
function mysql_stmt_close(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_close, mysql_lib),
                 Cchar,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Returns the value generated by auto increment column by the previous
insert / update statement.
"""
function mysql_insert_id(mysqlptr::MYSQL)
    return ccall((:mysql_insert_id, mysql_lib),
                 Culong,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Creates the sql string where the special chars are escaped
"""
function mysql_real_escape_string(mysqlptr::MYSQL,
                                  to::Vector{Uint8},
                                  from::String,
                                  length::Culong)
    return ccall((:mysql_real_escape_string, mysql_lib),
                 Uint32,
                 (Ptr{Cuchar},
                  Ptr{Uint8},
                  Ptr{Uint8},
                  Culong),
                 mysqlptr,
                 to,
                 from,
                 length)
end

"""
Creates a mysql_stmt handle. Should be closed with mysql_close_stmt
"""
function mysql_stmt_init(dbptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_init, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 dbptr)
end

function mysql_stmt_init(db::MySQLDatabaseHandle)
    return mysql_stmt_init(db.ptr)
end

"""
Creates the prepared statement. There should be only 1 statement
"""
function mysql_stmt_prepare(stmtptr::Ptr{Cuchar}, sql::String)
    s = utf8(sql)
    return ccall((:mysql_stmt_prepare, mysql_lib),
                 Cint, # TODO: Confirm proper type to use here
                 (Ptr{Cuchar}, Ptr{Cchar}, Culong),
                 stmtptr,      s,          length(s))
end

"""
Returns the error message for the recently invoked statement API
"""
function mysql_stmt_error(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_error, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Store the entire result returned by the prepared statement in the
bind datastructure provided by mysql_stmt_bind_result.
"""
function mysql_stmt_store_result(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_store_result, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Return the metadata for the results that will be received from
the execution of the prepared statement.
"""
function mysql_stmt_result_metadata(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_result_metadata, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Equivalent of `mysql_num_rows` for prepared statements.
"""
function mysql_stmt_num_rows(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_num_rows, mysql_lib),
                 Culonglong,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Equivalent of `mysql_fetch_row` for prepared statements.
"""
function mysql_stmt_fetch_row(stmtptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_fetch, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Bind the returned data from execution of the prepared statement
to a preallocated datastructure `bind`.
"""
function mysql_stmt_bind_result(stmtptr::Ptr{Uint8}, bind::Ptr{Cuchar})
    return ccall((:mysql_stmt_bind_result, mysql_lib),
                 Cchar,
                 (Ptr{Uint8}, Ptr{Cuchar}),
                 stmtptr,
                 bind)
end

"""
Executes the query and returns the status of the same.
"""
function mysql_query(mysqlptr::MYSQL, sql::String)
    return ccall((:mysql_query, mysql_lib),
                 Int8,
                 (Ptr{Cuchar}, Ptr{Cuchar}),
                 mysqlptr,
                 sql)
end

"""
Stores the result in to an object.
"""
function mysql_store_result(results::Ptr{Cuchar})
    return ccall((:mysql_store_result, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the field metadata.
"""
function mysql_fetch_fields(results::Ptr{Cuchar})
    return ccall((:mysql_fetch_fields, mysql_lib),
                 Ptr{MYSQL_FIELD},
                 (Ptr{Cuchar},),
                 results)
end


"""
Returns the row from the result set.
"""
function mysql_fetch_row(results::Ptr{Cuchar})
    return ccall((:mysql_fetch_row, mysql_lib),
                 MYSQL_ROW,
                 (Ptr{Cuchar},),
                 results)
end

"""
Frees the result set.
"""
function mysql_free_result(results::Ptr{Cuchar})
    return ccall((:mysql_free_result, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the number of fields in the result set.
"""
function mysql_num_fields(results::Ptr{Cuchar})
    return ccall((:mysql_num_fields, mysql_lib),
                 Int8,
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the number of records from the result set.
"""
function mysql_num_rows(results::Ptr{Cuchar})
    return ccall((:mysql_num_rows, mysql_lib),
                 Int64,
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the # of affected rows in case of insert / update / delete.
"""
function mysql_affected_rows(results::Ptr{Cuchar})
    return ccall((:mysql_affected_rows, mysql_lib),
                 Uint64,
                 (Ptr{Cuchar},),
                 results)
end

function mysql_autocommit(mysqlptr::MYSQL, mode::Int8)
    return ccall((:mysql_autocommit, mysql_lib),
                 Cchar, (Ptr{Void}, Cchar),
                 mysqlptr, mode)
end

function mysql_change_user(mysqlptr::MYSQL, user::String, passwd::String,
                           db::String = "")
    return ccall((:mysql_change_user, mysql_lib),
                 Cchar, (Ptr{Void}, Cstring, Cstring, Cstring),
                 mysqlptr, user, passwd, (db == "" ? C_NULL : db))
end

function mysql_character_set_name(mysqlptr::MYSQL)
    return ccall((:mysql_character_set_name, mysql_lib),
                 Cstring, (Ptr{Void},), mysqlptr)
end

function mysql_commit(mysqlptr::MYSQL)
    return ccall((:mysql_commit, mysql_lib), Cchar, (Ptr{Void},), mysqlptr)
end

function mysql_data_seek(result::MYSQL_RES, offset::Uint64)
    return ccall((:mysql_data_seek, mysql_lib),
                 Void, (Ptr{Void}, Culonglong),
                 result, offset-1)
end

function mysql_dump_debug_info(mysqlptr::MYSQL)
    return ccall((:mysql_dump_debug_info, mysql_lib),
                 Cint, (Ptr{Void},), mysqlptr)
end

function mysql_fetch_lengths(result::MYSQL_RES)
    return ccall((:mysql_fetch_lengths, mysql_lib), Ptr{Cuint}, (Ptr{Void},), result)
end

function mysql_field_count(mysqlptr::MYSQL)
    return ccall((:mysql_field_count, mysql_lib), Cuint, (Ptr{Void},), mysqlptr)
end

function mysql_field_seek(result::MYSQL_RES, offset::Cuint)
    return ccall((:mysql_field_seek, mysql_lib), Cuint, (ptr{Void}, Cuint),
                 result, offset-1)
end

function mysql_field_tell(result::MYSQL_RES)
    return ccall((:mysql_field_tell, mysql_lib), Cuint, (Ptr{Void},), result)
end

function mysql_get_client_info()
    return ccall((:mysql_get_client_info, mysql_lib), Ptr{Uint8}, ())
end

function mysql_get_client_version()
    return ccall((:mysql_get_client_version, mysql_lib), Culong, ())
end

function mysql_get_host_info(mysqlptr::MYSQL)
    return ccall((:mysql_get_host_info, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_get_proto_info(mysqlptr::MYSQL)
    return ccall((:mysql_get_proto_info, mysql_lib), Cuint, (Ptr{Void},), mysqlptr)
end

function mysql_get_server_info(mysqlptr::MYSQL)
    return ccall((:mysql_get_server_info, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_get_server_version(mysqlptr::MYSQL)
    return ccall((:mysql_get_server_version, mysql_lib), Culong, (Ptr{Void},), mysqlptr)
end

function mysql_get_ssl_cipher(mysqlptr::MYSQL)
    return ccall((:mysql_get_ssl_cipher, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_info(mysqlptr::MYSQL)
    return ccall((:mysql_info, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_kill(mysqlptr::MYSQL, pid::Uint)
    return ccall((:mysql_kill, mysql_lib), Cint, (PTr{Uint8}, Culong),
                                             mysqlptr, pid)
end

function mysql_server_end()
    return ccall((:mysql_server_end, mysql_lib), Void, ())
end

function mysql_server_init(argv::Vector{String})
    return ccall((:mysql_server_init, mysql_lib), Cint,
                  (Cint, Ptr{Ptr{Uint8}}, Ptr{Ptr{Uint8}}),
                  length(argv), argv, C_NULL)
end

function mysql_server_init()
    return ccall((:mysql_server_init, mysql_lib), Cint,
                  (Cint, Ptr{Ptr{Uint8}}, Ptr{Ptr{Uint8}}),
                  0, C_NULL, C_NULL)
end

function mysql_more_results(mysqlptr::MYSQL)
    retval = ccall((:mysql_more_results, mysql_lib), Cchar, (Ptr{Void},), mysqlptr)
    return retval == 1
end

function mysql_next_result(mysqlptr::MYSQL)
    return ccall((:mysql_next_result, mysql_lib), Cint, (Ptr{Void},),
                 mysqlptr)
end

function mysql_ping(mysqlptr::MYSQL)
    return ccall((:mysql_ping, mysql_lib), Cint, (Ptr{Void},), mysqlptr)
end

function mysql_real_query(mysqlptr::MYSQL, query::Vector{Uint8})
    return ccall((:mysql_real_query, mysql_lib), Cint, (Ptr{Void}, Ptr{Uint8}, Culong),
                 mysqlptr, query, length(query))
end

function mysql_real_query(mysqlptr::MYSQL, query::Ptr{Cuchar})
    return mysql_real_query(mysqlptr, query)
end

function mysql_refresh(mysqlptr::MYSQL, options::Uint32)
    return ccall((:mysql_refresh, mysql_lib), Cchar,
                 (Ptr{Void}, Cuint), mysqlptr, options)
end

function mysql_rollback(mysqlptr::MYSQL)
    return ccall((:mysql_rollback, mysql_lib), Cchar, (Ptr{Void},), mysqlptr)
end

function mysql_row_seek(result::MYSQL_RES, offset::Ptr{Void})
    return ccall((:mysql_row_seek, mysql_lib), Ptr{Void}, (Ptr{Void}, Ptr{Void}), result, offset)
end

function mysql_row_tell(result::MYSQL_RES)
    return ccall((:mysql_row_tell, mysql_lib), PTr{Void}, (Ptr{Void},),
                 result)
end

function mysql_select_db(mysqlptr::MYSQL, db::String)
    return ccall((:mysql_select_db, mysql_lib),
                 Cint, (Ptr{Void}, Ptr{Void}), mysqlptr, db)
end

function mysql_set_character_set(mysqlptr::MYSQL, csname::String)
    return ccall((:mysql_set_character_set, mysql_lib), Cint, (Ptr{Void}, Ptr{Void}), mysqlptr, csname)
end

function mysql_set_server_option(mysqlptr::MYSQL, option::Uint32)
    return ccall((:mysql_set_server_option, mysql_lib), Cint, (Ptr{Void}, Cint), mysqlptr, option)
end

function mysql_sqlstate(mysqlptr::MYSQL)
    return ccall((:mysql_sqlstate, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_ssl_set(mysqlptr::MYSQL, key::Ptr{Uint8}=C_NULL, cert::Ptr{Uint8}=C_NULL, ca::Ptr{Uint8}=C_NULL,
              capath::Ptr{Uint8}=C_NULL, cipher::Ptr{Uint8}=C_NULL)
    return ccall((:mysql_ssl_set, mysql_lib),
                 Cchar, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Uint8}),
                 mysqlptr, key, cert, ca, capath, cipher)
end

function mysql_stat(mysqlptr::MYSQL)
    return ccall((:mysql_stat, mysql_lib), Ptr{Uint8}, (Ptr{Void},), mysqlptr)
end

function mysql_thread_end()
    return ccall((:mysql_thread_end, mysql_lib), Void, ())
end

function mysql_thread_id(mysqlptr::MYSQL)
    return ccall((:mysql_thread_id, mysql_lib), Culong, (Ptr{Void},), mysqlptr)
end

function mysql_thread_init()
    return ccall((:mysql_thread_init, mysql_lib), Cchar, ())
end

function mysql_thread_safe()
    return ccall((:mysql_thread_safe, mysql_lib), Cint, ())
end

function mysql_use_result(mysqlptr::MYSQL)
    return ccall((:mysql_use_result, mysql_lib), Ptr{Void}, (Ptr{Void},),
                 mysqlptr)
end

function mysql_warning_count(mysqlptr::MYSQL)
    return ccall((:mysql_warning_count, mysql_lib), Cuint, (Ptr{Void},),
                 mysqlptr)
end
