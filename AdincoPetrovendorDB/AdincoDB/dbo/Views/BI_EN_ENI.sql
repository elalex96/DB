CREATE VIEW dbo.BI_EN_ENI
AS

SELECT 
	C.NumeroContrato		AS Contrato,
	E.DocumentoEntregable + 
		CASE WHEN ISNULL(I.NombreInstalacion,'') <> '' THEN ' - ' + LTRIM(I.NombreInstalacion) + ' '
		ELSE '' END
		+ '- ' + LTRIM(IE.idInstanciaEntregable)  	AS DocumentoEntregable,
	AR.NombreArea AS Area,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre	AS Usuario,
	U.Usuario	AS CorreoUsuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END			AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END		AS [Status],
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg)	AS DiasP,	--NVOS DIAS P PARA SHELL
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales,
	ISNULL(ML.MarcoLegal,'')	AS MarcoLegal,
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador,
	IE.idInstanciaEntregable	AS ID,
	E.Articulo,
	dbo.fnGetAprobadoresEntregable(CE.IdContratoEntregable)	AS Aprobador,
	dbo.fnGetRevisoresEntregable(CE.IdContratoEntregable)	AS Revisor,
	ISNULL(E.DeliverableName,E.DocumentoEntregable)+ '-' + LTRIM(IE.idInstanciaEntregable)	AS DeliverableName,
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)	AS MarcoLegalIngles,
	ISNULL(PRO.NombreProceso,'')	AS Proceso
FROM
	EN_InstanciasEntregable	IE (NOLOCK)
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(IE.Activo,0)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
	AND	IE.FechaCalculadaEntregaReg	IS NOT NULL
	AND	IE.FechasLimiteElaboracion	<	DATEADD(YEAR,4,GETDATE())
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CE.IdContrato	=	C.IdContrato
	AND	C.DescripcionContrato LIKE '%ENI%'
JOIN
	EN_Entregable	E	(NOLOCK)
	ON	CE.IdEntregable	=	E.IdEntregable
	AND	ISNULL(E.IsActivo,0)	=	1
	AND E.BITJOA = 0
JOIN
	EN_Area		AR	(NOLOCK)
	ON	CE.IdArea	=	AR.idArea
JOIN
	EN_Actividad	A	(NOLOCK)
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.EstadoID = 10000
JOIN
	EN_Actividad	AACT	(NOLOCK)
	ON	IE.ActividadID	=	AACT.ActividadID
LEFT JOIN
	EN_MarcoLegal	ML
	ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	AP_Usuario	U	(NOLOCK)
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	EN_DocumentoVersion	DV	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
LEFT JOIN
	EN_InstanciasEntregables_InstanciaActividad	IEIA	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
LEFT JOIN
	EN_InstanciasActividades IA	(NOLOCK)
	ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
LEFT JOIN
	EN_InstanciasProcesosFecha IPF	(NOLOCK)
	ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
LEFT JOIN
	EN_Procesos PRO	(NOLOCK)
	ON	IPF.IdProceso	=	PRO.IdProceso
LEFT JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	PRO.IdInstalacion	=	I.IdInstalacion
GROUP BY
	C.NumeroContrato,
	E.DocumentoEntregable + 
		CASE WHEN ISNULL(I.NombreInstalacion,'') <> '' THEN ' - ' + LTRIM(I.NombreInstalacion) + ' '
		ELSE '' END
		+ '- ' + LTRIM(IE.idInstanciaEntregable),
	AR.NombreArea,
	IE.FechaInicioElaboracion,
	IE.FechasLimiteAprobacion,
	U.Nombre,
	U.Usuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(ML.MarcoLegal,''),
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg,
	IE.idInstanciaEntregable,
	E.Articulo,
	CE.IdContratoEntregable,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable),
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal),
	ISNULL(PRO.NombreProceso,'')

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IE"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 325
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HA"
            Begin Extent = 
               Top = 6
               Left = 363
               Bottom = 136
               Right = 634
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HA2"
            Begin Extent = 
               Top = 6
               Left = 672
               Bottom = 136
               Right = 943
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO"
            Begin Extent = 
               Top = 6
               Left = 981
               Bottom = 136
               Right = 1244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 345
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CT"
            Begin Extent = 
               Top = 138
               Left = 383
               Bottom = 268
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'BI_EN_ENI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'BI_EN_ENI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'BI_EN_ENI';

