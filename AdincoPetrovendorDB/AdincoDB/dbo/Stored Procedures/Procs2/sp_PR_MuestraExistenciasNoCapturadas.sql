/****** Object:  StoredProcedure [dbo].[MuestraExistenciasNoCapturadas]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE PROCEDURE [dbo].[sp_PR_MuestraExistenciasNoCapturadas]
AS
BEGIN
-- --------------------------------
SET NOCOUNT ON
-- --------------------------------
declare  @Tanques table 

(
	IDEstacion				INT,
	Estacion				VARCHAR(30),
	IDTanque				INT,
	Tanque					VARCHAR(30),
	ExistenciaDiaAnterior	DECIMAL(24,8)
)

INSERT INTO @Tanques
(
	IDEstacion,
	Estacion,
	IDTanque,
	Tanque
)
SELECT
	PR_Estacion.Id,
	PR_Estacion.Nombre,
	PR_Tanque.Id,
	PR_Tanque.Nombre
FROM
	PR_Estacion
INNER JOIN
	PR_Tanque
	ON PR_Estacion.Id = PR_Tanque.Estacion

DELETE t
FROM
	@Tanques	t
JOIN
	PR_existencia e
	ON	t.IDEstacion	=	e.Estacion
	AND	t.IDTanque		=	e.Tanque
WHERE
	CONVERT(DATE,e.Fecha) = CONVERT(DATE,GETDATE())


UPDATE	T
	SET	ExistenciaDiaAnterior	=	e.Existencia
FROM
	@Tanques	t
JOIN
	PR_existencia e
	ON	t.IDEstacion	=	e.Estacion
	AND	t.IDTanque		=	e.Tanque
WHERE
	CONVERT(DATE,e.Fecha) = CONVERT(DATE,DATEADD(dd,-1,GETDATE()))

SELECT	*
FROM	@Tanques
end

