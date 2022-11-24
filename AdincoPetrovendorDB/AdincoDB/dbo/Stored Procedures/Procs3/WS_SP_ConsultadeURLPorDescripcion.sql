-- =============================================
-- Author:	Reyna Olvera
-- ALTER date: 17/08/2022
-- Description:	Obtiene la url del webservice para ejecutar algun metodo por medio de Descripción
-- =============================================
CREATE PROCEDURE [dbo].[WS_SP_ConsultadeURLPorDescripcion] 
	@Descripcion VARCHAR(100)
AS
BEGIN
	SELECT *
	FROM dbo.WS_URLsMetodos
	WHERE Descripcion = @Descripcion
END