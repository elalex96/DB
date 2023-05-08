-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CodActivacion]
@codigo varchar(100),
@IdProveedor int

AS
DECLARE @FechaRegistro as datetime = GETDATE()

BEGIN

insert into AP_CodActivacion (CodigoActivacion,Activo,FechaRegistro,IdProveedor) values(@codigo,'0',@FechaRegistro, @IdProveedor)
	
END


