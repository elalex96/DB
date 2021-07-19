USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_UsuarioOBS_Combos'
)
    DROP PROCEDURE DEA_SP_UsuarioOBS_Combos;

/****** Object:  StoredProcedure [dbo].[sp_CentroCostoFiltro_Grd]    Script Date: 13/07/2021 01:17:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[DEA_SP_UsuarioOBS_Combos]
@TipoConsulta NVARCHAR(MAX),
@ContratoId INT = 0
AS
BEGIN

	IF @TipoConsulta ='CONTRATOS'
	BEGIN 

		SELECT C.IdContrato, CONCAT(C.NumeroContrato, ISNULL(' - '+ AC.NombreAreaContractual,'')) AS Contrato
		FROM Adinco..CO_Contrato C
		JOIN Adinco..CO_AreaContractual AC
		ON C.IdAreaContractual = AC.IdAreaContractual
		WHERE C.IdContrato IN (
		    --(3),   --> MEXICO PRUEBAS
			10038, --> CNH-A4.OGARRIO/2018
			10044, --> CNH-R03-L01-G-TMV-02/2018
			10045, --> CNH-R03-L01-G-TMV-03/2018
			10046, --> CNH-R03-L01-AS-CS-14/2018
			10144, --> CNH-DEMMA
			10145 --> CNH-WD ADMIN
		)	
		ORDER BY C.NumeroContrato ASC 

	END 

	IF @TipoConsulta ='USUARIOxCONTRATO'
	BEGIN 

		SELECT U.IdUsuario, CONCAT(U.Nombre,' (', U.Correo,')') AS Usuario
		FROM S_Usuario U
		JOIN S_UsuarioProveedor UP
		ON U.IdUsuario = UP.IdUsuario
		WHERE UP.IdContrato = @ContratoId
		GROUP BY U.IdUsuario, U.Nombre, U.Correo
		ORDER BY U.Nombre
	END 
			
END

