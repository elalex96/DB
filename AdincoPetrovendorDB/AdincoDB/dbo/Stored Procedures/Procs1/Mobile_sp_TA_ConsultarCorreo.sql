-- =============================================
-- Author:	Daniel AC
-- Create date: 04/11/2020
-- Description:Consultar plantilla de correo por asunto
-- =============================================
CREATE PROCEDURE [dbo].[Mobile_sp_TA_ConsultarCorreo]
    -- Add the parameters for the stored procedure here
    @Asunto NVARCHAR(MAX)
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    /*CONSULTAR DETALLE DE CORREO Y DEL SERVIDOR DE CORREO*/
    SELECT HTML,
           Asunto,
           CuentaRegistro,
           Contrasena,
           SMTP,
           Puerto,
           BBC
    FROM TA_Correo AS C
        INNER JOIN S_CorreoServidor AS S
            ON S.IdCorreoServidor = C.IdServidor
    WHERE C.Asunto = @Asunto;

END;


