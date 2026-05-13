-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AutentificarCodigo]
@Codigo varchar(100),
@IdProveedor int
AS
BEGIN
select * from AP_CodActivacion where CodigoActivacion = @Codigo and Activo = '0' and datediff(SECOND,FechaRegistro,GETDATE()) < 1800 and IdProveedor = @IdProveedor
END


