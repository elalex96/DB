USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_ValidarProveedor_CARTACN'
)
    DROP PROCEDURE SP_DEA_ValidarProveedor_CARTACN;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update: 25-01-2021
-- Description:	issue #930/ Optimización de sp
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update: 08/07/2121
-- Description:	issue #1201/ Bug de dea carta de proveedor a operadora 
-- =============================================
-- Author:		Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ValidarProveedor_CARTACN]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int, 
	@IdAceptacion INT
AS
BEGIN
	DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT,	@CONFIGURACION_CARTA NVARCHAR(100),@IdContrato INT;

	SELECT TOP 1
		@RFC_ACTUAL = P.RFC,
		@IdContrato = PD.IdContrato
	FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
		JOIN dbo.S_Proveedor AS P (NOLOCK) 
			ON AP.IdProveedor = P.IdProveedor
		JOIN MM_Pedido AS PD (NOLOCK) 
			ON AP.IdPedido = PD.IdPedido
	WHERE AP.IdAceptacionPedido = @IdAceptacion;

	SET @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor (NOLOCK)
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1);

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 
		SELECT 'CAMBIAR_PROCESO'
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

			SELECT 'CAMBIAR_PROCESO'

		END
		ELSE
		BEGIN

			SELECT 'SEGUIR_PROCESO'

		END
		
	END 

END