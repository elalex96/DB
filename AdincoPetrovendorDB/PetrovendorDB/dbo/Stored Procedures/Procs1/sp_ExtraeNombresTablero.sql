-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 05/11/2020
-- Description:	Visualiza los nombre de los tableros del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExtraeNombresTablero]--10128,10041
    @idUsuario INT,
    @idContrato INT,
	@isAdmin	INT = NULL
AS
BEGIN
		SELECT	
			TU.Id 'IdTableroUsuario',
			T.Id 'IdTablero',
			TU.IdUsuario,
			T.IdContrato,
			T.NombreMostrar,
			C.NumeroContrato,
			AC.NombreAreaContractual
			FROM Petrovendor..AP_TablerosUsuario AS TU
		JOIN Petrovendor..AP_Tableros AS T ON TU.IdTablero = T.Id 
		JOIN Adinco..CO_Contrato AS C ON T.IdContrato = C.IdContrato
		JOIN Adinco..CO_AreaContractual	AC ON	C.IdAreaContractual	=	AC.IdAreaContractual
		WHERE 
		TU.IdUsuario = @idUsuario
		AND T.IdContrato = @idContrato
		AND T.Activo = 1
		AND TU.Activo = 1
END

--[dbo].[sp_ExtraeNombresTablero] 0,0