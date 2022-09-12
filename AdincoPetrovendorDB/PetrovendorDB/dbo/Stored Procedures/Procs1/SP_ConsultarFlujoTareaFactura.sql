USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarFlujoTareaFactura]    Script Date: 08/09/2022 12:58:45 p. m. ******/
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
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/09/2022
-- Description:	Issue #1987  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
ALTER  PROCEDURE [dbo].[SP_ConsultarFlujoTareaFactura] @IdProveedor INT, @IdUsuario INT
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
		FROM	TA_FlujoTarea (NOLOCK) FT 
		JOIN	TA_TipoFlujoTarea (NOLOCK) AS TF
			ON FT.IdTipoFlujo = TF.IdTipoFlujoTarea 
		JOIN dbo.TA_Aprobador (NOLOCK) A 
			ON  FT.IdFlujoTarea = A.IdFlujoTarea 
		JOIN dbo.S_Usuario (NOLOCK) U 
			ON A.IdUsuario = U.IdUsuario 
		WHERE
		FT.IdProveedor = @IdProveedor
		AND FT.IdTipoOperacion = 10 --> CTE TIPO FACTURA 
		AND ISNULL(FT.Eliminado,0)=0
		AND U.Activo = 1 --EL USUARIO ESTE ACTIVO
		ORDER BY FT.Nombre ASC
						

	END