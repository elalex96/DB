USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_MM_CartaValidarProveedor'
)
    DROP PROCEDURE SP_MPY_MM_CartaValidarProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 15-06-17
-- Description:	
-- =============================================
-- =============================================  
-- Author: Alexander Gomez  
-- Create date: 18-02-21  
-- Description: adecuacion para carta CN para DEA  
-- =============================================  
-- =============================================
-- Author:		Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
CREATE procedure [dbo].[SP_MPY_MM_CartaValidarProveedor] 
	-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT,
@IdProveedor NVARCHAR(20) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here 

	DECLARE @RFC_ACTUAL NVARCHAR(200), 
		@EXISTE_RFC INT, 
		@IdContrato INT, 
		@CONFIGURACION_CARTA NVARCHAR(100);

	SELECT TOP 1
		@RFC_ACTUAL = P.RFC,
		@IdContrato = PD.IdContrato
	FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
		JOIN dbo.S_Proveedor AS P (NOLOCK) 
			ON AP.IdProveedor = P.IdProveedor
		JOIN MM_Pedido AS PD (NOLOCK) 
			ON AP.IdPedido = PD.IdPedido
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

	set @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor (NOLOCK)
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1)

	IF @EXISTE_RFC > 0
	BEGIN
		
		SELECT 'EXISTE_PROVEEDOR_DEA'

	END
	ELSE
	BEGIN

		--SE VERIFICA EL RFC ESTE EN LA CONFIGURACION
		SET @CONFIGURACION_CARTA = (SELECT
										TipoConfiguracion
									FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
									WHERE IdContrato = @IdContrato
										AND TipoConfiguracion = 'CARTA_PR_PR'
										AND Operadora = 1
										AND Activo = 1);

		IF @CONFIGURACION_CARTA = 'CARTA_PR_PR'
		BEGIN

			SELECT 'EXISTE'

		END
		ELSE
		BEGIN

			SELECT 
			CASE 
				WHEN  COUNT(AP.IdAceptacionPedido)  > 0 THEN 'EXISTE' 
				ELSE 'NO_EXISTE' END 
			FROM dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
			WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

		END

	END;

END