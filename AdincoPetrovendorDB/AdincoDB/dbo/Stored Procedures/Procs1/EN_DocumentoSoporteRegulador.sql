-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:Btón de subir documento soporte, checa si elentregable aprobado ya cuenta con documento,
--en caso de no ser así se visualiza un botón
-- =============================================
CREATE PROCEDURE [dbo].[EN_DocumentoSoporteRegulador]--10061,3,257819
    @idUsuario INT,
    @IdContrato INT,
    @idInstanciaEntregable INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdLineaTiempo  INT = 0,	
			@idTipoOperacion INT = 0,
			@CountFechaRegulador int = 0;


    SELECT 
		TOP	1	@IdLineaTiempo	=	MAX(IdLineaTiempo),
				@idTipoOperacion	=	idTipoOperacion 
    FROM 
		EN_HistorialAprobacionesLineaTiempo
     WHERE 
		idInstanciaEntregable	=	@idInstanciaEntregable
		AND idTipoOperacion NOT IN (8,9)
		AND Activo	=	1
     GROUP BY 
		IdHistorialAprobacionesVersion,
        idTipoOperacion 
     ORDER BY 
		IdHistorialAprobacionesVersion	DESC;

	 SELECT
		CASE ISNULL(BitContieneAcuse,0)
		WHEN 0
			THEN 0
		ELSE
		1 END,
		@idTipoOperacion,
		ISNULL(COUNT(FechaRealEntregaRegulador),0)
	 FROM 
		EN_InstanciasEntregable 
	WHERE
		idInstanciaEntregable	=	@idInstanciaEntregable
		GROUP BY BitContieneAcuse
END;