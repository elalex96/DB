-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	Regresa a la parte web los parámetros que contiene el servidor de correos y tenga funcionalidad y puedan ser enviados
-- =============================================

-- SP_TaConsultaServidor 0,'procura@adinco.mx'
create PROCEDURE [dbo].[SP_TaConsultaServidor_OLD] 

@IdCorreoServidor int,
@CuentaRegistro varchar(100)

AS
BEGIN

	SELECT CuentaRegistro , Contrasena , SMTP  , Puerto , BBC 
	FROM S_CorreoServidor 
	WHERE @IdCorreoServidor in (0, IdCorreoServidor ) 
	and rtrim(@CuentaRegistro) in ('',rtrim(CuentaRegistro))

END