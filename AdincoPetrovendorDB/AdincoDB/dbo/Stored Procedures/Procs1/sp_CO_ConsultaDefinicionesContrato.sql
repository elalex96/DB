CREATE PROCEDURE [dbo].[sp_CO_ConsultaDefinicionesContrato] 
	@IdContrato INT,
	@IdUsuario INT = 1
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- ---------------------------------------------------
-- 20190610	BAAC	Me modifica para agregar marco legal a loas definiciones
-- =============================================
SET NOCOUNT ON;

DECLARE
	@IdRonda	INT,
	@IdTipoContrato	INT,
	@Ronda		VARCHAR(50)

SELECT	@IdTipoContrato	=	IdTipoContrato,
		@IdRonda	=	ISNULL(IdRonda, 10000)
FROM CO_CONTRATO
WHERE IdContrato = @IdContrato

SELECT	@Ronda	=	LTRIM(RTRIM(REPLACE(Ronda,'Ronda','')))
FROM	EN_Rondas
WHERE	idRonda	=	@IdRonda

         -- Insert statements for procedure here
SELECT	
	D.IdDefinicion,
    D.Termino,
    D.Definicion,
	ISNULL(D.Articulo,'')	AS Articulo,
	ISNULL(D.Inciso,'')		AS Inciso,
	ML.MarcoLegal
FROM
	CO_Definicion D
JOIN
	EN_MarcoLegal	ML
	ON	D.IdMarcoLegal	=	ML.IdMarcoLegal
WHERE
--	D.IdTipoContrato	=	@IdTipoContrato
--	AND
	ML.MarcoLegal	NOT LIKE '%RONDA%'

UNION

SELECT	
	D.IdDefinicion,
    D.Termino,
    D.Definicion,
	ISNULL(D.Articulo,'')	AS Articulo,
	ISNULL(D.Inciso,'')		AS Inciso,
	ML.MarcoLegal
FROM
	CO_Definicion D
JOIN
	EN_MarcoLegal	ML
	ON	D.IdMarcoLegal	=	ML.IdMarcoLegal
WHERE
	--D.IdTipoContrato	=	@IdTipoContrato
	--AND
	ML.MarcoLegal	LIKE '%RONDA%'
	AND
	ML.MarcoLegal	LIKE	'%' + @Ronda + '%'
END
