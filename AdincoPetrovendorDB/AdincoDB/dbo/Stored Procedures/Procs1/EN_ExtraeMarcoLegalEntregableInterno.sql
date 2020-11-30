CREATE PROCEDURE [dbo].[EN_ExtraeMarcoLegalEntregableInterno]--10061,3
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    -- =================================================================
    -- Author:	Reyna Olvera
    -- Create date: 14/11/2019
    -- Description:	Extrae los marcos legales para entregables internos
    -- =================================================================
    SET NOCOUNT ON;
	IF @idUsuario = 10437 --@idContrato in (10112)	--@idContrato in (10093, 10108, 10110, 10119, 10120, 10122)
	BEGIN
		SELECT ml.IdMarcoLegal,
			   ml.MarcoLegal
		FROM EN_MarcoLegal ml
		--join EN_Entregable e ON ml.IdMarcoLegal=e.IdMarcoLegal
		--join EN_ContratoEntregable ce on e.IdEntregable= ce.IdEntregable AND ce.IdContrato=@idContrato
		where ml.Activo=1 --AND e.IsActivo= 1 AND ce.Activo=1 and ml.IsInterno=0
		GROUP BY  ml.IdMarcoLegal,
			   ml.MarcoLegal
		ORDER BY ml.MarcoLegal
	END
	ELSE
	BEGIN
		SELECT ml.IdMarcoLegal,
			   ml.MarcoLegal
		FROM EN_MarcoLegal ml
		join EN_Entregable e 
			ON ml.IdMarcoLegal=e.IdMarcoLegal
			AND E.BITJOA = 0
		join EN_ContratoEntregable ce on e.IdEntregable= ce.IdEntregable AND ce.IdContrato=@idContrato
		where ml.Activo=1 AND e.IsActivo= 1 AND ce.Activo=1 and ml.IsInterno=0
		GROUP BY  ml.IdMarcoLegal,
			   ml.MarcoLegal
		ORDER BY ML.MARCOLEGAL
	END
END
