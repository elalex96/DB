-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description:	Datos Basicos de las tareas creadas por el proveedor
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Modified date: 23/01/2018
-- Description:	Se agrega el tipo de flujo
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Modified date: 09/10/2019
-- Description:	mostrar el nombre de los aprobadores del flujo relacionado al centro de costo
-- =============================================
-- Author:		Alexander Gomez
-- Modified date: 03/07/2020
-- Description:	agregado del campo solo notificacion para los flujos de documentos
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarFlujoTareaProveedor] 

@IdProveedor INT, @IdTipoOperacion INT = 2
AS
	BEGIN
		SET NOCOUNT ON
				
		SELECT	
		FT.IdFlujoTarea, 
		FT.Nombre, 
		FT.Descripcion, 
		TF.Nombre AS TipoFlujo, 
		FT.Predeterminado, 
		FT.SoloNotificar,
		 STUFF(
        (
            SELECT ', ' + U.Nombre AS [text()]
                FROM dbo.TA_Aprobador AS A
				INNER JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario
                WHERE A.IdFlujoTarea=FT.IdFlujoTarea 
                ORDER BY  A.NoSecuencia ASC 
            FOR XML PATH('')
        ), 1, 1, '') AS Aprobadores
		FROM		TA_FlujoTarea FT
		INNER JOIN	TA_TipoFlujoTarea AS TF
			ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
		WHERE
					IdProveedor = @IdProveedor
					AND IdTipoOperacion = @IdTipoOperacion
					AND
						(	Eliminado IS NULL
							OR		Eliminado = 0 )
	 
    

	END
