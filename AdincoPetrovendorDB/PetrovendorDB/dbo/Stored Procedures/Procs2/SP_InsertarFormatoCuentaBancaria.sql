-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertarFormatoCuentaBancaria]
@Documento nvarchar(max),
@FileName varchar(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		insert into [dbo].[PV_FormatoDeSolicitudCuentaBancaria](
		Documento,
		FechaRegistro,
		NombreArchivo
		)
		values(
		@Documento,
		getdate(),
		@FileName
		)

	select @@identity

END

