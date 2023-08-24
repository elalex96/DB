USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'FI_ActualizarErrorSATFactura'
)
    DROP PROCEDURE FI_ActualizarErrorSATFactura;
/****** Object:  StoredProcedure [dbo].[FI_ActualizarErrorSATFactura]    Script Date: 07/08/2023 05:16:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: <22/08/2023>
-- Description:	Actualizar si se tiene que actualizar el error sat 
-- =============================================
CREATE PROCEDURE [dbo].[FI_ActualizarErrorSATFactura] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdContrato INT,
@IdFactura INT,
@IdAceptacionPedido INT,
@ErrorSAT NVARCHAR(MAX),
@IdLectorSAT INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ErrorSAT_ NVARCHAR(MAX)
	DECLARE @UUID_ NVARCHAR(MAX)
	DECLARE @IdLectorXMLSAT_ INT
	DECLARE @Cambios NVARCHAR(MAX)

    SELECT @ErrorSAT_ = ISNULL(ErroSAT,0),
	@IdLectorXMLSAT_ = IdLectorXMLSAT,
	@UUID_  = UUID
	FROM FI_Factura (NOLOCK)
	WHERE IdFactura = @IdFactura

	IF RTRIM(LTRIM(UPPER(@ErrorSAT_))) <> RTRIM(LTRIM(UPPER(@ErrorSAT))) 
	BEGIN 
		IF @IdLectorSAT <> 0
		BEGIN 

			UPDATE FI_Factura 
			SET ErroSAT = @ErrorSAT,
			IdLectorXMLSAT = @IdLectorSAT		
			WHERE IdFactura = @IdFactura

			-- AGREGAR BITACORA DE REGISTRO
			SET @Cambios = CONCAT('Contrato: ',@IdContrato,', UUID: ',@UUID_,' - [ ErrorSAT- Antes: ', @ErrorSAT_,', Después: ', @ErrorSAT,', LectorSAT- Antes: ',ISNULL(@IdLectorXMLSAT_,0), ', Después: ',@IdLectorSAT ,' ]')
			INSERT INTO BitacoraErrores(HResult, Mensaje, StackTrace, IdUsuario, IdProveedor,FechaRegistro)
			VALUES (@IdFactura,CONCAT('ACTUALIZACIÓN VALIDACIÓN SAT ACEPTACION #',@IdAceptacionPedido),@Cambios,@IdUsuario,@IdProveedor, GETDATE())

		END 
		ELSE
		BEGIN 
		
			UPDATE FI_Factura 
			SET ErroSAT = @ErrorSAT		
			WHERE IdFactura = @IdFactura

			-- AGREGAR BITACORA DE REGISTRO
			SET @Cambios = CONCAT('Contrato: ',@IdContrato,', UUID: ',@UUID_, '- [ ErrorSAT- Antes: ', @ErrorSAT_,', Después: ', @ErrorSAT,' ]')
			INSERT INTO BitacoraErrores(HResult, Mensaje, StackTrace, IdUsuario, IdProveedor,FechaRegistro)
			VALUES (@IdFactura,CONCAT('ACTUALIZACIÓN VALIDACIÓN SAT ACEPTACION #',@IdAceptacionPedido),@Cambios,@IdUsuario,@IdProveedor, GETDATE())
		END
	END 



END