CREATE VIEW [dbo].[ConsultaRegalíasRenaissance]
AS
     SELECT TOP (100) PERCENT C.NumeroContrato, 
                              AC.NombreAreaContractual, 
                              MCH.IdMetodoCalculoHidrocarburoMes, 
                              MCH.Mes, 
                              CO_TipoHidrocarburo.Hidrocarburo, 
                              ROUND(MCH.Precio, 2) AS [Precio], 
                              ISNULL(MCH.Volumen, 0) AS Volumen, 
                              ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0) AS [Valor], 
                              ROUND(MCH.TasaRegalia, 2) AS [TasaRegalia], 
                              ROUND((MCH.TasaRegalia / 100) * (ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0)), 2) AS Regalia
     FROM CP_MetodoCalculoHidrocarburoMes MCH (NOLOCK)
          JOIN dbo.CO_Contrato C (NOLOCK)
			ON C.IdContrato = MCH.IdContrato
          JOIN dbo.CO_AreaContractual AC (NOLOCK)
			ON AC.IdAreaContractual = C.IdAreaContractual
          JOIN CO_TipoHidrocarburo (NOLOCK)
			ON MCH.IdTipoHidrocarburo = CO_TipoHidrocarburo.TipoHidrocarburo
     WHERE MCH.IdContrato IN(10001, 10002, 10003)
     ORDER BY AC.NombreAreaContractual, 
              MCH.Mes DESC;