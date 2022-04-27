USE [Petrovendor]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ConsultarFlujoTareaFactura'
)
    DROP PROCEDURE SP_ConsultarFlujoTareaFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarFlujoTareaFactura]    Script Date: 26/04/2022 06:52:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 29-06-17
-- Description:	consultar todos los flujos de aprobación de factura 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_ConsultarFlujoTareaFactura] @IdProveedor INT, @IdUsuario INT
AS
	BEGIN
		SET NOCOUNT ON

		SELECT		
		FT.IdFlujoTarea, 
		FT.Nombre, 
		FT.Descripcion, 
		TF.Nombre AS TipoFlujo, 
		A.IdAprobador,
		A.NoSecuencia,
		U.Nombre AS Aprobador, 
		U.IdUsuario
		FROM	TA_FlujoTarea FT
		JOIN	TA_TipoFlujoTarea AS TF
			ON FT.IdTipoFlujo = TF.IdTipoFlujoTarea 
		LEFT JOIN dbo.TA_Aprobador A 
			ON  FT.IdFlujoTarea = A.IdFlujoTarea 
		LEFT JOIN dbo.S_Usuario U 
			ON A.IdUsuario = U.IdUsuario 
		WHERE
		FT.IdProveedor = @IdProveedor
		AND FT.IdTipoOperacion = 10 --> CTE TIPO FACTURA 
		AND ISNULL(FT.Eliminado,0)=0
		ORDER BY FT.Nombre ASC
						

	END