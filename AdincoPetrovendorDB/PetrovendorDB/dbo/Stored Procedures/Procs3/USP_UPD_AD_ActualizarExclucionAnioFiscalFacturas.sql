use Petrovendor
go
drop proc if exists USP_UPD_AD_ActualizarExclucionAnioFiscalFacturas
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/01/2023>
-- Description:	<Actualizar registro de exclucion de año fiscal para carga de facturas>
-- =============================================
-- Author:		<Luis David>
-- Create date: <20/ABR/26>
-- Description:	<Actualización de registro>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_AD_ActualizarExclucionAnioFiscalFacturas]
	-- Add the parameters for the stored procedure here
	@RFCOperadora NVARCHAR(100),
	@AnioExclucion INT,
	@FechaVigencia DATETIME,
	@ModificadoPorSesion INT,
	@Activo BIT,
	@Id INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE FacturasExcluirRestriccionAnioFiscal
	SET FechaVigencia = @FechaVigencia,
		ModificadoPor = @ModificadoPorSesion,
		Activo = @Activo,
		ModificadoEl = GETDATE()
	WHERE RFCOperadora = @RFCOperadora
		AND AnioExclucion = @AnioExclucion;

END
