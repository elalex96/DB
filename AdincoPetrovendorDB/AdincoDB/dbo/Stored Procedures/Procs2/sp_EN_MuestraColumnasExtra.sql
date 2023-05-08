CREATE PROCEDURE dbo.sp_EN_MuestraColumnasExtra --3,10061,'false',''
	@idContrato	INT,
	@idUsuario	INT,
	@isTab	BIT,
	@nombreTab VARCHAR(150)
AS
BEGIN
-- ============================================================
-- Modulo:			ENTREGABLES - Configuración (SHELL)
--------------------------------------------------------------
-- 20200116		BAAC	Creación de SP
-- ============================================================
SET NOCOUNT ON

DECLARE @Mostrar INT = 0

IF(@isTab='false')
	BEGIN
		SELECT @Mostrar =	CASE WHEN CC.NombreContratista LIKE '%Shell%' 
										THEN 1
								--WHEN CC.NombreContratista LIKE '%SMART%' THEN 1
							     WHEN CC.NombreContratista LIKE '%Repsol%' 
										THEN 2
								 ELSE	0
								 END
		FROM
			CO_Contratista	CC
		JOIN
			CO_Contrato	C
			ON	CC.IdContratista	=	C.IdContratista
		WHERE
			C.IdContrato	=	@idContrato
			--SET @Mostrar = 1 --tbEntregableTodos
	END
ELSE
	BEGIN
		SELECT @Mostrar =	CASE WHEN CC.NombreContratista LIKE '%Shell%' 
										THEN 1
							     WHEN CC.NombreContratista LIKE '%Repsol%' 
										THEN 0
								 ELSE	1
								 END
		FROM
			CO_Contratista	CC
		JOIN
			CO_Contrato	C
			ON	CC.IdContratista	=	C.IdContratista
		WHERE
			C.IdContrato	=	@idContrato
	END

SELECT @Mostrar
 AS Mostrar

END