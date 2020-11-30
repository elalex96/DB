-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10-10-2019
-- Description:	Consulta los anuncios para el contrato
-- =============================================
CREATE PROCEDURE sp_CO_ExtraeAnunciosContrato --3,10061
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN


    SELECT Anuncio,
           URL,
           CASE
               WHEN GETDATE() < DATEADD(DAY, DiasNovedad, FechaInicio) THEN
                   '<span class="small-badge bg-red" style="height:11px; width:11px"></span>'
               ELSE
                   '<span class="small-badge bg-yellow"></span>'
           END AS Color,
		     CASE
               WHEN GETDATE() < DATEADD(DAY, DiasNovedad, FechaInicio) THEN
                   1
               ELSE
                   0
           END AS IsColorRojo
    FROM CO_Anuncio	(NOLOCK)
    WHERE Idcontrato = @IdContrato
          AND GETDATE()
          BETWEEN FechaInicio AND FechaVigencia;
END;