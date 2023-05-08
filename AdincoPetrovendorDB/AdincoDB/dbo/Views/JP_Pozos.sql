CREATE VIEW [dbo].[JP_Pozos]
AS
     SELECT CONCAT(I.NombreInstalacion, '/IDCNH(SUBSUELO)/', SUBSTRING(C.NumeroContrato, 13, 5), '/', C.IDRegFiducidiario, '/Compartido') AS Concatenado, 
            I.NombreInstalacion AS 'Nombre del Pozo', 
            SUBSTRING(C.NumeroContrato, 13, 5) AS 'Area Contractual', 
            C.NumeroContrato AS 'Contrato', 
            I.UTMX AS 'Longitud', 
            I.UTMY AS 'Latitud', 
            '' AS Espacio1, 
            UPPER(SUBSTRING(CC.RazonSocial, 0, CHARINDEX(' ', CC.RazonSocial))) AS 'Compañia', 
            UPPER(SUBSTRING(CC.RazonSocial, 0, 3)) AS 'ID Cia', 
            '' AS 'Región', 
            '' AS 'ID Reg', 
            '' AS Espacio2, 
            '' AS 'Compartido Vista?', 
            CC.IDSIPAC AS 'FMP Contratista(ID)', 
            C.IDRegFiducidiario AS 'FMP Contrato (ID)', 
            SUBSTRING(C.NumeroContrato, 13, 5) AS 'Area', 
            CO.NombreCampo AS 'Campo', 
            '' AS Espacio3, 
            '' AS 'Terrateniente', 
            '' AS Espacio4, 
            '' AS 'ID CNH ( SUBSUELO)', 
            '' AS 'Tipo de producto'
     FROM dbo.CO_Instalacion I(NOLOCK)
          JOIN dbo.CO_AreaContractual AC(NOLOCK) ON I.IdAreaContractual = AC.IdAreaContractual
          JOIN dbo.CO_Contrato C(NOLOCK) ON AC.IdAreaContractual = C.IdAreaContractual
          JOIN dbo.CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
          LEFT JOIN dbo.PD_Campo CO(NOLOCK) ON I.IdCampo = CO.IdCampo
     WHERE CC.IdContratista IN(10005, 10006);
