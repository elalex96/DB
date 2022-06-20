USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_UsuarioSolicitudCNProveedorExtranjero'
)
    DROP PROCEDURE DEA_SP_UsuarioSolicitudCNProveedorExtranjero;
	GO
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]    Script Date: 08/06/2022 03:15:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEA_SP_UsuarioSolicitudCNProveedorExtranjero]
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
		ORDER BY C.NumeroContrato ASC 

	END 

	IF @TipoConsulta ='PROVEEDORES'
	BEGIN 

		SELECT P.IdProveedor, CONCAT(P.RFC,' - ',P.RazonSocial,' [',P.IdProveedor,']') AS Proveedor
		FROM S_Proveedor P		
		WHERE P.IdNacionalidad =2	--> CTE NACIONALIDAD EXTRANJERA		
		ORDER BY P.RFC, P.RazonSocial asc
	END 
			
END