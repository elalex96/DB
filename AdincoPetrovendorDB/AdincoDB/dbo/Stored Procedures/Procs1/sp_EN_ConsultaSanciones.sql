CREATE PROCEDURE dbo.sp_EN_ConsultaSanciones
	@IdContrato	INT,
	@IdUsuario	INT
AS
BEGIN
-- ============================================================
-- Modulo:				CONTRATO / Entregables
-- Parametros Entrada:	COntrato, Usuario
-- Salida:				Lista de las sanciomnes y el monto de las mismas
-- Description:			Muestra un listado de las saciones y el monto de las mismas de acuerdo al valor del salario minimo
-- ------------------------------------------------------------
-- 20190610	BAAC	Me modifica para agregar marco legal a loas definiciones
-- ============================================================
SET NOCOUNT ON

DECLARE @VSM	MONEY = 0

SELECT
	@VSM	=	Valor
FROM
	FI_VSM
WHERE
	GETDATE()	BETWEEN IdFechaIni	AND IdFechaFin
	AND
	Activo = 1

SELECT
	ML.MarcoLegal AS [Marco Legal],
	S.Articulo	AS [Artículo],
	S.Titulo	AS [Título],
	S.Capitulo	AS [Capítulo],
	SA.NombreSancionador	AS [Sancionador],
	S.TipoInfraccion	AS [Tipo de Infracción],
	FORMAT(S.VSM_Minimo,'N','en-us')	AS [VSM Minimo],
	FORMAT(S.VSM_Maximo,'N','en-us')	AS [VSM Maximo],
	FORMAT(S.VSM_Minimo * @VSM, 'C', 'en-us') AS [Importe MN Mínimo],
	--S.VSM_Minimo * @VSM	AS [Importe MN Mínimo],
	FORMAT(S.VSM_Maximo * @VSM, 'C', 'en-us') AS [Importe MN Máximo]
	--S.VSM_Maximo * @VSM	AS [Importe MN Máximo]
FROM
	EN_Sanciones	S
JOIN
	EN_MarcoLegal	ML
	ON	S.IdMarcoLegal	=	ML.IdMarcoLegal
JOIN
	EN_Sancionador	SA
	ON	S.IdSancionador	=	SA.IdSancionador
ORDER BY
	ML.MarcoLegal,
	SA.NombreSancionador,
	S.TipoInfraccion

END

