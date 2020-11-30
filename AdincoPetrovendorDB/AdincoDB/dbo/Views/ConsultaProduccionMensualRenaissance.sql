CREATE VIEW [dbo].[ConsultaProduccionMensualRenaissance]
AS
     SELECT TOP (100) PERCENT CC.NumeroContrato, 
                              AC.NombreAreaContractual, 
                              PMP.IdReporteVolumenesProduccionPetroleo, 
                              PMP.MesReporte, 
                              PMP.VolumenPetroleoPuntoMedicion, 
                              PMP.GradosAPI, 
                              PMP.ContenidoAzufre, 
                              PMP.VolumenPetroleoAutoconsumo, 
                              PMP.MetanoC1, 
                              PMP.EtanoC2, 
                              PMP.PropanoC3, 
                              PMP.ButanoC4, 
                              PMP.MetanoC1Autoconsumo, 
                              PMP.EtanoC2Autoconsumo, 
                              PMP.PropanoC3Autoconsumo, 
                              PMP.ButanoC4Autoconsumo, 
                              (ISNULL(PMP.VolumenCondensadoPuntoMedicion, 0) + ISNULL(PMP.VolumenCondensablePuntoMedicion, 0)) AS [VolumenCondensadoPuntoMedicion], 
                              (ISNULL(PMP.VolumenCondensadoAutoconsumo, 0) + ISNULL(PMP.VolumenCondensableAutoconsumo, 0)) AS [VolumenCondensadoAutoconsumo]
     FROM PR_VolumenMensualProduccionPetroleo PMP (NOLOCK)
          JOIN dbo.CO_Contrato CC (NOLOCK)
			ON CC.IdContrato = PMP.IdContrato
          LEFT JOIN dbo.CO_AreaContractual AC (NOLOCK)
			ON AC.IdAreaContractual = CC.IdAreaContractual
     WHERE CC.[IdContrato] IN(10001, 10002, 10003)
     ORDER BY CC.NumeroContrato, 
              PMP.MesReporte DESC; 