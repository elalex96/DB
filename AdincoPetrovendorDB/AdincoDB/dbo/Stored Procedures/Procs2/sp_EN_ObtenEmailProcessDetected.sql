CREATE PROCEDURE dbo.sp_EN_ObtenEmailProcessDetected
	@idContrato	INT,
	@idUsuario	INT
AS
BEGIN
-- ============================================================
-- Modulo:			ENTREGABLES - Extrae email de process detected
--------------------------------------------------------------
-- ============================================================
SET NOCOUNT ON

DECLARE @Email VARCHAR(MAX);

SELECT
	@Email =	CASE WHEN CC.NombreContratista LIKE '%Shell%' THEN 'Joshua.Gamboa@shell.com'
				  -- WHEN CC.NombreContratista LIKE '%Murphy%' THEN 'reyna.olvera@adinco.mx'
				ELSE	''
				END
FROM
	CO_Contratista	CC
JOIN
	CO_Contrato	C
	ON	CC.IdContratista	=	C.IdContratista
WHERE
	C.IdContrato	=	@idContrato

SELECT @Email AS Email

END


