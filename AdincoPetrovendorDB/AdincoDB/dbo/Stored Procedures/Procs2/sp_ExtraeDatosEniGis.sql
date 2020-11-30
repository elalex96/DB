-- =============================================
-- =============================================
CREATE PROCEDURE sp_ExtraeDatosEniGis
	@IdContrato int = 0--Dependiendo del parametro que nos manden o que nosotros mostremos 10049
AS
BEGIN

CREATE TABLE #Clasificaciones(Id int identity (1,1),
							  NameField VARCHAR(150),
							  HeaderTextField VARCHAR (300),
							  ImageURLField VARCHAR(300),
							  NavigateUrlField VARCHAR(300),
							  TextField VARCHAR(300));

SELECT @IdContrato = 3 --10049

INSERT INTO #Clasificaciones( NameField ,
							  HeaderTextField,
							  ImageURLField ,
							  NavigateUrlField,
							  TextField)
SELECT
	'ContratoNameField'	as NameField,
    'Contrato con CNH: ' + NumeroContrato as HeaderTextField,
    'https://upload.wikimedia.org/wikipedia/commons/6/6c/Cnh_logo.jpg' AS ImageURLField,
    'https://adinco.mx/2/Contrato/InfoGeneralContrato.aspx' AS NavigateUrlField,
    DescripcionContrato as TextField
FROM
	CO_CONTRATO
WHERE idcontrato = @IdContrato	--10049

INSERT INTO #Clasificaciones( NameField ,
							  HeaderTextField,
							  ImageURLField ,
							  NavigateUrlField,
							  TextField)
SELECT
	LTRIM(ReceptorEntregable) + 'NameField' as NameField,
	LTRIM(ReceptorEntregable) as HeaderTextField,
	CASE LTRIM(ReceptorEntregable)
		WHEN 'ASEA' THEN 'https://organizacionrodriguez.com.mx/wp-content/uploads/2017/07/ASEA-LOGO.jpg'
		WHEN 'CNH' THEN 'https://upload.wikimedia.org/wikipedia/commons/6/6c/Cnh_logo.jpg'
		WHEN 'FMP' THEN 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWm7GWK_CJ9qaNQET9pEAcTJMKJFTovX0Zi2TaFpjRWTkKBref'
		WHEN 'SHCP'	THEN 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFryhiJ-nZlv7uSYcSAnA-6Al96flX1w-K6cATp2UUf4lKRMCS'
		WHEN 'SENER' THEN 'https://pbs.twimg.com/media/De4DNpxX4AMfjc0.jpg'
		WHEN 'CONAGUA (Comisión Nacional del Agua)' THEN 'https://pbs.twimg.com/profile_images/1173942663592185858/P0XJmeyw_400x400.jpg'
		WHEN 'SE' THEN 'https://pbs.twimg.com/profile_images/1174080896409858048/VrcX2i8i_400x400.jpg'
		WHEN 'SEMAR (Secretaría de Marina)' THEN 'https://pbs.twimg.com/profile_images/1191347341523144711/va27Vmnt_400x400.jpg'
		WHEN 'SEMARNAT' THEN 'https://pbs.twimg.com/profile_images/1174147940136476672/4wCMSpXT_400x400.jpg'
		ELSE 'http://procura.adinco.mx/assets/00/img/SMPS_Logo.png'
	END		AS ImageURLField,
	'../../2/Entregables/InstanciasEntregablesExterno.aspx' AS NavigateUrlField,
	'Archivos de Obligaciones cargadas de: ' + LTRIM(ReceptorEntregable) as TextField
FROM
	EN_Entregable	E
JOIN
	EN_CONTRATOENTREGABLE	CE
	ON	E.IDENTREGABLE = CE.IDENTREGABLE
	AND CE.IDCONTRATO = @IdContrato	--10049
	AND	E.IsActivo = 1	
	AND	CE.Activo = 1
	AND E.BITJOA = 0
JOIN
	EN_INSTANCIASENTREGABLE	IE
	ON	CE.IDCONTRATOENTREGABLE = IE.IDCONTRATOENTREGABLE
JOIN
	EN_Actividad	A
	ON	iE.ActividadID	=	A.ActividadID
	AND	A.EstadoID = 10003
JOIN
	EN_ReceptorEntregable	RE
	ON	E.IdReceptorEntregable	=	RE.IdReceptorEntregable
GROUP BY
	LTRIM(ReceptorEntregable)
ORDER BY
	LTRIM(ReceptorEntregable)

SELECT * FROM #Clasificaciones ORDER BY Id ASC
	
END