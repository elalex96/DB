-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
create PROCEDURE [dbo].[sp_EN_ExtraeActividades]
    @idContrato INT,
    @idUsuario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdActividad,
           NombreActividad,
           Dias,
		   Case diasNaturales
		   When 0
		   then 'Hábiles'
		   When 1
			then 'Días naturales'
			End as 'Tipodias'
           --,E.DocumentoEntregable AS 'Documento Entregable',
           --E.Descripcion AS 'Descripcion Entregable',
           --E.Articulo AS 'Articulo',
           --E.ArchivoEntregable AS 'Archivo Entregable',
           --R.Regulador AS 'Regulador',
           --F.FrecuenciaEntregable AS 'Frecuencia'
    FROM En_actividades A
        --JOIN dbo.EN_Entregable E
        --    ON E.IdEntregable = A.IdEntregable
        --JOIN dbo.CO_Regulador R
        --    ON R.IdRegulador = E.IdRegulador
        --JOIN dbo.EN_FrecuenciaEntregable F
        --    ON F.IdFrecuenciaEntregable = E.IdFrecuenciaEntregable;

END;