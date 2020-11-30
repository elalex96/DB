-- =============================================
-- Author:	Daniel AC
-- Create date: 29-06-17
-- Description:	consultar todos los flujos de aprobación de factura 
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
		FROM		TA_FlujoTarea FT
		INNER JOIN	TA_TipoFlujoTarea AS TF
			ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
		LEFT JOIN dbo.TA_Aprobador A ON A.IdFlujoTarea = FT.IdFlujoTarea
		LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario
		WHERE
		IdProveedor = @IdProveedor
		AND IdTipoOperacion = 10 --> TIPO FACTURA 
		AND ISNULL(Eliminado,0)=0
		ORDER BY FT.Nombre ASC
						

	END