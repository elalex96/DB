
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-09-2018>
-- Description:	<Se guarda la politica de pago de un proveedor>
-- =============================================

CREATE PROCEDURE PP_SP_GuardarPoliticasPago	
	@IdProveedor INT,
	@PoliticasPago NVARCHAR(max),
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DECLARE @IdPolitica INT = (SELECT IdPolicitaPago FROM dbo.PP_PoliticasPago WHERE IdProveedor = @IdProveedor)

	IF(@IdPolitica IS NOT NULL)
	BEGIN
		UPDATE dbo.PP_PoliticasPago
			SET PoliticaPago = @PoliticasPago,
				IdUsuarioCreador = @IdUsuario,
                FechaRegistro = GETDATE()
			WHERE IdProveedor = @IdProveedor
	END
	ELSE
	BEGIN
		INSERT INTO dbo.PP_PoliticasPago
		(
		    PoliticaPago,
		    FechaRegistro,
		    IdUsuarioCreador,
		    IdProveedor
		)
		VALUES
		(   @PoliticasPago,                   -- PoliticaPago - nvarchar(max)
		    GETDATE(), -- FechaRegistro - smalldatetime
		    @IdUsuario,                     -- IdUsuarioCreador - int
		    @IdProveedor                      -- IdProveedor - int
		)
	END
END