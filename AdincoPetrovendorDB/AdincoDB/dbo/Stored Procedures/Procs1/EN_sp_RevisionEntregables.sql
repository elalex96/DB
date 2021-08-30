DROP PROCEDURE IF EXISTS EN_sp_RevisionEntregables
GO
CREATE PROCEDURE EN_sp_RevisionEntregables
@ContratoId INT,
@Consecutivo VARCHAR(500)
AS
BEGIN
	SELECT E.Consecutivo, 
	CC.NumeroContrato, CA.NombreContratista, 
	CASE WHEN ISNULL(CE.ACTIVO,0) = 0 THEN 'NO' ELSE 'SI' END AS Activo, 
	COUNT(IE.idInstanciaEntregable) AS Programaciones, 
	COUNT(HA.IDINSTANCIAENTREGABLE) AS Cargados,
	ISNULL(A.NombreArea,'') AS Area,
	U.Nombre	AS Elaborador
	FROM EN_Entregable E
	JOIN EN_ContratoEntregable CE
		ON E.IdEntregable = CE.IdEntregable
	JOIN CO_Contrato CC
		ON CE.IdContrato = CC.IdContrato
	JOIN
		EN_EntregableRonda	ER
		ON	E.IdEntregable	=	ER.IdEntregable
		AND CC.IdRonda	=	ER.idRonda
	JOIN
		CO_Contratista CA
		ON	CC.IdContratista = CA.IdContratista
		AND CA.IdContratista NOT IN (1,2,10000,10001,10002,10003,10004,10005,10006,10007,10009,10011,10015,
		10016,10017,10021,10022,10023,10026,10027,10028,10029,10030,10031,10032,10033,10034,10035,10036,
		10037,10038,10039,10040,10041,10042,10043,10044,10045,10046,10048,10049,10051,10052,10053,10054,
		10060,10064,10057,10058,10056)
	LEFT JOIN
		EN_AREA A
		ON	CE.IdArea	=	A.idArea
	LEFT JOIN
		EN_Actividad	AA
		ON	CE.IdContratoEntregable = AA.IdContratoEntregable
		AND AA.EstadoID = 10000
	LEFT JOIN
		AP_USUARIO U
		ON	AA.idUsuario = U.UsuarioID
	LEFT JOIN EN_InstanciasEntregable IE
		ON CE.IdContratoEntregable = IE.IdContratoEntregable

	LEFT JOIN
		EN_HistorialAprobacionesLineaTiempo	HA
		ON	IE.idInstanciaEntregable = HA.idInstanciaEntregable
		AND HA.idTipoOperacion = 4
	WHERE 
	E.CONSECUTIVO = @Consecutivo
	GROUP BY
		E.Consecutivo, 
		CC.NumeroContrato, CA.NombreContratista, CASE WHEN ISNULL(CE.ACTIVO,0) = 0 THEN 'NO' ELSE 'SI' END,
		ISNULL(A.NombreArea,''),
		U.Nombre
	ORDER BY
		CA.NombreContratista,
		CC.NumeroContrato
END