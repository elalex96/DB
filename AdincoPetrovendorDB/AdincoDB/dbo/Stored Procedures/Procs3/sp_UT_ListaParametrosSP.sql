-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	List all stored procedure parameters for C# class
-- =============================================
CREATE PROCEDURE [dbo].[sp_UT_ListaParametrosSP] 
-- Add the parameters for the stored procedure here
@NombreSP NVARCHAR(MAX)
AS
         BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @resultado AS NVARCHAR(MAX);
             SELECT @resultado = 'try'+CHAR(13)+'{'+CHAR(13)+'UsuarioActual = new DTO_Usuario();'+CHAR(13)+'UsuarioActual = (DTO_Usuario)Session["Usuario"];'+CHAR(13)+'DataTable _consulta = new DataTable();'+CHAR(13)+'string _nombresp = "'+@NombreSP+'";'+CHAR(13)+'List<DTO_ParametrosSP> _lista = new List <DTO_ParametrosSP>();'+CHAR(13);
             SELECT @resultado+='DTO_ParametrosSP _param = new DTO_ParametrosSP();'+CHAR(13);
             DECLARE @resultado2 AS NVARCHAR(MAX);
             SELECT @resultado2 = COALESCE(@resultado2+'', '')+'// Agrega parametro para '+name+CHAR(13)+'_param = new DTO_ParametrosSP();'+CHAR(13)+'_param.NombreParametro = "'+name+'";'+CHAR(13)+'_param.Valor = "VALORAQUI";'+CHAR(13)+CASE TYPE_NAME(user_type_id)
                                                                                                                                                                                                                                                 WHEN 'varchar'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._String);'
                                                                                                                                                                                                                                                 WHEN 'nvarchar'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._String);'
                                                                                                                                                                                                                                                 WHEN 'int'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Integer );'
                                                                                                                                                                                                                                                 WHEN 'datetime'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._DateTime );'
                                                                                                                                                                                                                                                 WHEN 'money'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Decimal  );'
                                                                                                                                                                                                                                                 WHEN 'decimal'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Decimal  );'
                                                                                                                                                                                                                                                 WHEN 'bit'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Bool   );'
                                                                                                                                                                                                                                                 WHEN 'float'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Float   );'
                                                                                                                                                                                                                                                 WHEN 'date'
                                                                                                                                                                                                                                                 THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._DateTime );'
                                                                                                                                                                                                                                                 ELSE TYPE_NAME(user_type_id)
                                                                                                                                                                                                                                             END+CHAR(13)+'_lista.Add(_param);'+CHAR(13)
             FROM sys.parameters
             WHERE object_id = OBJECT_ID(@NombreSP);
             SELECT @resultado+CHAR(13)+@resultado2+CHAR(13)+'   try
                {
                    //Ejecuta el SP
                    _consulta = DBConnection.StoreProcedureSQL(_nombresp, _lista);
                    //Clear Devexpress Controls
                    //ASPxEdit.ClearEditorsInContainer(this);
                    //ScriptManager.RegisterStartupScript(Page, Page.GetType(), "JSScript", Mensajes._C_RegistroGuardado.ToString(), false);

                }
                catch (Exception ex)
                {
                     BitacoraE bitacora = new BitacoraE();
                bitacora.HResult = ex.HResult;
                bitacora.StackTrace = ex.StackTrace;
                bitacora.Mensaje = ex.Message;
                bitacora.IdUsuario = Session["IdUsuario"] == null ? 0 : (int)Session["IdUsuario"];
                bitacora.IdProveedor = Session["IdContrato"] == null ? 0 : (int)Session["IdContrato"];
                BitacoraErrores.InsertarError(bitacora);
                }
            }

            catch (Exception ex)
            {

                BitacoraE bitacora = new BitacoraE();
                bitacora.HResult = ex.HResult;
                bitacora.StackTrace = ex.StackTrace;
                bitacora.Mensaje = ex.Message;
                bitacora.IdUsuario = Session["IdUsuario"] == null ? 0 : (int)Session["IdUsuario"];
                bitacora.IdProveedor = Session["IdContrato"] == null ? 0 : (int)Session["IdContrato"];
                BitacoraErrores.InsertarError(bitacora);
            }';
         END;