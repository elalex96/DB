CREATE PROCEDURE [dbo].[sp_RevisarVigenciaCompraDirecta] (@IdOperacion INT)
AS
BEGIN
    SELECT vigencia.DiaVencimiento,
           tOperacion.FechaRegistro,
           DATEADD(DAY, 365, tOperacion.FechaRegistro) AS FechaVigencia,
           tOperacion.IdProveedor
    FROM dbo.TA_Operacion tOperacion
        INNER JOIN dbo.TA_Vencimiento vigencia
            ON tOperacion.IdVigencia = vigencia.IdVencimiento
    WHERE tOperacion.IdOperacion = @IdOperacion

	---Version anterior Josué Modifica para abrir la vigencia de las aprobaciones  a 1 año a partir de la fecha de registro
	--SELECT vigencia.DiaVencimiento,
 --          tOperacion.FechaRegistro,
 --          DATEADD(DAY, vigencia.DiaVencimiento,, tOperacion.FechaRegistro) AS FechaVigencia,
 --          tOperacion.IdProveedor
 --   FROM dbo.TA_Operacion tOperacion
 --       INNER JOIN dbo.TA_Vencimiento vigencia
 --           ON tOperacion.IdVigencia = vigencia.IdVencimiento
 --   WHERE tOperacion.IdOperacion = @IdOperacion
END
