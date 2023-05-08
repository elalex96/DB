--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [dbo].[Mobile_InicioOperadoras]
@IdContratista INT,
@IdLicitacion INT =0
--Created by: Luis David 
--Description: muestra las operadoras que se tienen registradas en la aplicación móvil
AS
BEGIN
	IF @IdContratista > 0
	BEGIN
		SELECT 
		c.IdContrato,ac.IdAreaContractual,
		ac.NombreAreaContractual AS 'AreaContractual',
		c.NumeroContrato		AS 'Contrato',			r.Ronda			 AS 'Ronda',
		tc.TipoContratoCorto    AS 'Modalidad',			ac.SuperficieKm2 AS 'Superficie',
		c.ValorRegaliaAdicional AS 'RegaliaAdicional',	uac.NombreUbicacion AS 'Tipo',
		CONCAT('https://adinco.mx/account/GoogleMaps/MapaAreaContractual.aspx?IdArea=',ac.IdAreaContractual) AS 'URLMap',
		cta.RazonSocial AS 'Contratista',
		isnull(ParticipacionEstado,'No aplica') ParticipacionEstado
		FROM 
		dbo.CO_AreaContractual AS ac
	    JOIN dbo.CO_Contrato AS c ON c.IdAreaContractual = ac.IdAreaContractual
		JOIN dbo.CO_TipoContrato AS tc ON c.IdTipoContrato = tc.IdTipoContrato
		JOIN dbo.CO_UbicacionAC AS uac ON uac.IdUbicacionAC = ac.IdUbicacionAC
		JOIN dbo.CO_Contratista AS cta ON c.IdContratista = cta.IdContratista
		JOIN dbo.EN_Rondas AS r ON r.idRonda = c.IdRonda
		WHERE c.IdContratista = @IdContratista
		and ContratoFicticio != 1
    END
	IF @IdLicitacion > 0
	BEGIN
		SELECT 
		c.IdContrato,ac.IdAreaContractual,
		ac.NombreAreaContractual AS 'AreaContractual',
		c.NumeroContrato		AS 'Contrato',			r.Ronda			 AS 'Ronda',
		tc.TipoContratoCorto    AS 'Modalidad',			ac.SuperficieKm2 AS 'Superficie',
		c.ValorRegaliaAdicional AS 'RegaliaAdicional',	uac.NombreUbicacion AS 'Tipo',
		CONCAT('https://adinco.mx/account/GoogleMaps/MapaAreaContractual.aspx?IdArea=',ac.IdAreaContractual) AS 'URLMap',
		cta.RazonSocial AS 'Contratista',
		isnull(ParticipacionEstado,'No aplica') ParticipacionEstado
		FROM 
		dbo.CO_AreaContractual AS ac
	    left JOIN dbo.CO_Contrato AS c ON c.IdAreaContractual = ac.IdAreaContractual
		left JOIN dbo.CO_TipoContrato AS tc ON c.IdTipoContrato = tc.IdTipoContrato
		left JOIN dbo.CO_UbicacionAC AS uac ON uac.IdUbicacionAC = ac.IdUbicacionAC
		left JOIN dbo.CO_Contratista AS cta ON c.IdContratista = cta.IdContratista
		left JOIN dbo.EN_Rondas AS r ON r.idRonda = c.IdRonda
		WHERE r.idRonda = @IdLicitacion
		and ContratoFicticio != 1
	END
END