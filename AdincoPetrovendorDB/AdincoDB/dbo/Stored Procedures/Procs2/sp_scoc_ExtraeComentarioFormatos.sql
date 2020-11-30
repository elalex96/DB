-- =============================================
-- Author:		Reyna Olvera
-- Create date:	20181206
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_scoc_ExtraeComentarioFormatos]
    @IdContrato INT,
    @IdUsuario INT,
    @MesResporte DATE,
    @Hidrocarburo NVARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;
	DECLARE @idProducto INT;

    SELECT @idProducto = ProductoNominacionID
    FROM CO_ClasificacionProductoNominacion
    WHERE NombreCNH = @Hidrocarburo;

    SELECT ObservacionesContratista,
           ObservacionesComercializador
    FROM SCOC_ComentariosReportes
    WHERE IdContrato = @IdContrato
          AND MesReporte = @MesResporte
          AND ProductoNominacionID = @idProducto;
END;