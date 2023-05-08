-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarDocumentoAltaCuentaBancaria]
@Documento nvarchar(max),
@IdCuentaBancaria int,
@IdTipoDocumento int,
@IdProveedor int,
@FileName varchar(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	insert into PV_DocumentoCuentaBancaria(
	Documento,
    EstatusAprobacion,
    IsActivo,
    FechaRegistro,
	IdTipoDocumento,
	IdCuentaBancaria,
	EnviadoPor,
	FileNameDoc
	)
	values(
    @Documento,
	2,
	1,
	getdate(),
	@IdTipoDocumento,
	@IdCuentaBancaria,
	@IdProveedor,
	@FileName
	)
	select @@Identity

END

