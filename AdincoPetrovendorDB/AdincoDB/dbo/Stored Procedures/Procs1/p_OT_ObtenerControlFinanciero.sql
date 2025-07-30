IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_OT_ObtenerControlFinanciero'
)
    DROP PROCEDURE p_OT_ObtenerControlFinanciero;
GO
CREATE PROC [dbo].[p_OT_ObtenerControlFinanciero] 
	@pIdOTSolicitud int
AS
BEGIN

CREATE TABLE #tmpAcumulados
(
    impE1 decimal(15, 5),
    impSE1 decimal(15, 5),
    afMenE1 decimal(15, 5),
    afMenSE1 decimal(15, 5),
    afAcumE1 decimal(15, 5),
    --
    impE2 decimal(15, 5) null,
    impSE2 decimal(15, 5) null,
    afMenE2 decimal(15, 5) null,
    afMenSE2 decimal(15, 5) null,
    afAcumE2 decimal(15, 5) null,
    impE3 decimal(15, 5) null,
    impSE3 decimal(15, 5) null,
    afMenE3 decimal(15, 5) null,
    afMenSE3 decimal(15, 5) null,
    afAcumE3 decimal(15, 5) null,
    impE4 decimal(15, 5) null,
    impSE4 decimal(15, 5) null,
    afMenE4 decimal(15, 5) null,
    afMenSE4 decimal(15, 5) null,
    afAcumE4 decimal(15, 5) null,
    impE5 decimal(15, 5) null,
    impSE5 decimal(15, 5) null,
    afMenE5 decimal(15, 5) null,
    afMenSE5 decimal(15, 5) null,
    afAcumE5 decimal(15, 5) null,
    impE6 decimal(15, 5) null,
    impSE6 decimal(15, 5) null,
    afMenE6 decimal(15, 5) null,
    afMenSE6 decimal(15, 5) null,
    afAcumE6 decimal(15, 5) null,
    impE7 decimal(15, 5) null,
    impSE7 decimal(15, 5) null,
    afMenE7 decimal(15, 5) null,
    afMenSE7 decimal(15, 5) null,
    afAcumE7 decimal(15, 5) null,
    impE8 decimal(15, 5) null,
    impSE8 decimal(15, 5) null,
    afMenE8 decimal(15, 5) null,
    afMenSE8 decimal(15, 5) null,
    afAcumE8 decimal(15, 5) null,
    impE9 decimal(15, 5) null,
    impSE9 decimal(15, 5) null,
    afMenE9 decimal(15, 5) null,
    afMenSE9 decimal(15, 5) null,
    afAcumE9 decimal(15, 5) null,
    impE10 decimal(15, 5) null,
    impSE10 decimal(15, 5) null,
    afMenE10 decimal(15, 5) null,
    afMenSE10 decimal(15, 5) null,
    afAcumE10 decimal(15, 5) null,
    impE11 decimal(15, 5) null,
    impSE11 decimal(15, 5) null,
    afMenE11 decimal(15, 5) null,
    afMenSE11 decimal(15, 5) null,
    afAcumE11 decimal(15, 5) null,
    impE12 decimal(15, 5) null,
    impSE12 decimal(15, 5) null,
    afMenE12 decimal(15, 5) null,
    afMenSE12 decimal(15, 5) null,
    afAcumE12 decimal(15, 5) null,
    impE13 decimal(15, 5) null,
    impSE13 decimal(15, 5) null,
    afMenE13 decimal(15, 5) null,
    afMenSE13 decimal(15, 5) null,
    afAcumE13 decimal(15, 5) null,
    impE14 decimal(15, 5) null,
    impSE14 decimal(15, 5) null,
    afMenE14 decimal(15, 5) null,
    afMenSE14 decimal(15, 5) null,
    afAcumE14 decimal(15, 5) null,
    impE15 decimal(15, 5) null,
    impSE15 decimal(15, 5) null,
    afMenE15 decimal(15, 5) null,
    afMenSE15 decimal(15, 5) null,
    afAcumE15 decimal(15, 5) null,
    impE16 decimal(15, 5) null,
    impSE16 decimal(15, 5) null,
    afMenE16 decimal(15, 5) null,
    afMenSE16 decimal(15, 5) null,
    afAcumE16 decimal(15, 5) null,
    impE17 decimal(15, 5) null,
    impSE17 decimal(15, 5) null,
    afMenE17 decimal(15, 5) null,
    afMenSE17 decimal(15, 5) null,
    afAcumE17 decimal(15, 5) null,
    impE18 decimal(15, 5) null,
    impSE18 decimal(15, 5) null,
    afMenE18 decimal(15, 5) null,
    afMenSE18 decimal(15, 5) null,
    afAcumE18 decimal(15, 5) null,
    impE19 decimal(15, 5) null,
    impSE19 decimal(15, 5) null,
    afMenE19 decimal(15, 5) null,
    afMenSE19 decimal(15, 5) null,
    afAcumE19 decimal(15, 5) null,
    impE20 decimal(15, 5) null,
    impSE20 decimal(15, 5) null,
    afMenE20 decimal(15, 5) null,
    afMenSE20 decimal(15, 5) null,
    afAcumE20 decimal(15, 5) null
)

DECLARE @noEstimaciones INT,
        @e1 VARCHAR(20),
        @e2 VARCHAR(20),
        @e3 VARCHAR(20),
        @e4 VARCHAR(20),
        @e5 VARCHAR(20),
        @e6 VARCHAR(20),
        @e7 VARCHAR(20),
        @e8 VARCHAR(20),
        @e9 VARCHAR(20),
        @e10 VARCHAR(20),
        @e11 VARCHAR(20),
        @e12 VARCHAR(20),
        @e13 VARCHAR(20),
        @e14 VARCHAR(20),
        @e15 VARCHAR(20),
        @e16 VARCHAR(20),
        @e17 VARCHAR(20),
        @e18 VARCHAR(20),
        @e19 VARCHAR(20),
        @e20 VARCHAR(20),
        @c1 VARCHAR(20),
        @c2 VARCHAR(20),
        @c3 VARCHAR(20),
        @c4 VARCHAR(20),
        @c5 VARCHAR(20),
        @c6 VARCHAR(20),
        @c7 VARCHAR(20),
        @c8 VARCHAR(20),
        @c9 VARCHAR(20),
        @c10 VARCHAR(20),
        @c11 VARCHAR(20),
        @c12 VARCHAR(20),
        @c13 VARCHAR(20),
        @c14 VARCHAR(20),
        @c15 VARCHAR(20),
        @c16 VARCHAR(20),
        @c17 VARCHAR(20),
        @c18 VARCHAR(20),
        @c19 VARCHAR(20),
        @c20 VARCHAR(20),
        @i INT,
        @folioAux VARCHAR(50),
        @consecutivoAux INT,
        @importeOT DECIMAL(15, 5)

SELECT IdOTEstimacion = est.IdOTEstimacion,
       est.FolioEstimacion,
       Concepto = scm.Concepto,
       DescripcionMat = scm.Descripcion,
       Unidad = u.Unidad,
       CantidadOT = CAST(scm.Cantidad AS DECIMAL(15, 5)),
       CantidadEstimacion = CAST(ISNULL(est.Cantidad, 0) AS DECIMAL(15, 5)),
       PrecioUnitario = CAST(scm.PrecioUnitario AS DECIMAL(15, 5)),
       Consecutivo = ISNULL(est.Consecutivo, 0),
       TotalEstimacion = CAST(ISNULL(est.Cantidad, 0) * est.PrecioUnitario AS DECIMAL(15, 5)),
       TotalOT =
       (
           SELECT SUM(Cantidad * PrecioUnitario)
           FROM SC_Materiales ST1	(NOLOCK)
           WHERE ST1.IdSCMaterial = otm.IdSCMaterial
       )
INTO #tmpEstimaciones
FROM 
	OT_Solicitud ot (NOLOCK)
    INNER JOIN 
		OT_SolicitudMaterial otm (NOLOCK)
        ON otm.idOTSolicitud = ot.IdOTSolicitud
		AND ot.IdOTSolicitud = @pIdOTSolicitud
    INNER JOIN 
		SC_Materiales scm	(NOLOCK)
        ON scm.IdSCMaterial = otm.IdSCMaterial
    INNER JOIN 
		Petrovendor.dbo.[PV_MM_MaterialUnidad] u	(NOLOCK)
        ON u.IdUnidad = scm.IdUnidad
    INNER JOIN 
		vwOTEstimacion est	(NOLOCK)
        ON est.IdOTSolicitud = ot.IdOTSolicitud
           AND est.IdSCMaterial = otm.IdSCMaterial
WHERE ot.IdOTSolicitud = @pIdOTSolicitud

SELECT @noEstimaciones = 
	COUNT(DISTINCT IdOTEstimacion), @i  = 1
FROM 
	#tmpEstimaciones

SELECT FolioEstimacion,
       i = IDENTITY(INT, 1, 1),
       consecutivo = MAX(consecutivo)
INTO #tmpI
FROM #tmpEstimaciones
WHERE FolioEstimacion IS NOT NULL
GROUP BY FolioEstimacion

WHILE @i <= 20
BEGIN
    SELECT @folioAux = FolioEstimacion,
           @consecutivoAux = consecutivo
    FROM #tmpI
    WHERE i = @i

    IF @i = 1
        SET @e1 = @folioAux
    IF @i = 2
        SET @e2 = @folioAux
    IF @i = 3
        SET @e3 = @folioAux
    IF @i = 4
        SET @e4 = @folioAux
    IF @i = 5
        SET @e5 = @folioAux
    IF @i = 6
        SET @e6 = @folioAux
    IF @i = 7
        SET @e7 = @folioAux
    IF @i = 8
        SET @e8 = @folioAux
    IF @i = 9
        SET @e9 = @folioAux
    IF @i = 10
        SET @e10 = @folioAux
    IF @i = 11
        SET @e11 = @folioAux
    IF @i = 12
        SET @e12 = @folioAux
    IF @i = 13
        SET @e13 = @folioAux
    IF @i = 14
        SET @e14 = @folioAux
    IF @i = 15
        SET @e15 = @folioAux
    IF @i = 16
        SET @e16 = @folioAux
    IF @i = 17
        SET @e17 = @folioAux
    IF @i = 18
        SET @e18 = @folioAux
    IF @i = 19
        SET @e19 = @folioAux
    IF @i = 20
        SET @e20 = @folioAux

    IF @i = 1
        SET @c1 = @consecutivoAux
    IF @i = 2
        SET @c2 = @consecutivoAux
    IF @i = 3
        SET @c3 = @consecutivoAux
    IF @i = 4
        SET @c4 = @consecutivoAux
    IF @i = 5
        SET @c5 = @consecutivoAux
    IF @i = 6
        SET @c6 = @consecutivoAux
    IF @i = 7
        SET @c7 = @consecutivoAux
    IF @i = 8
        SET @c8 = @consecutivoAux
    IF @i = 9
        SET @c9 = @consecutivoAux
    IF @i = 10
        SET @c10 = @consecutivoAux
    IF @i = 11
        SET @c11 = @consecutivoAux
    IF @i = 12
        SET @c12 = @consecutivoAux
    IF @i = 13
        SET @c13 = @consecutivoAux
    IF @i = 14
        SET @c14 = @consecutivoAux
    IF @i = 15
        SET @c15 = @consecutivoAux
    IF @i = 16
        SET @c16 = @consecutivoAux
    IF @i = 17
        SET @c17 = @consecutivoAux
    IF @i = 18
        SET @c18 = @consecutivoAux
    IF @i = 19
        SET @c19 = @consecutivoAux
    IF @i = 20
        SET @c20 = @consecutivoAux

    SET @i = @i + 1
    SET @folioAux = null
END

SELECT Concepto,
       DescripcionMat,
       Unidad,
       CantidadOT,
       nEstimaciones = @noEstimaciones,
       PrecioUnitario,
       Importe = CantidadOT * PrecioUnitario,
       nE1 = isnull(@e1, ''),
       cantE1 = SUM(   case
                           when FolioEstimacion = @e1 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE1 = cast(SUM(   case
                               when FolioEstimacion = @e1 then
                                   CantidadEstimacion
                               else
                                   0
                           end
                       ) * PrecioUnitario as decimal(15, 5)),
       cantSE1 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c1 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE1 = abs(cast((CantidadOT - SUM(   case
                                                  when Consecutivo <= @c1 then
                                                      CantidadEstimacion
                                                  else
                                                      0
                                              end
                                          )
                         ) * PrecioUnitario as decimal(15, 5))
                   ),
       nE2 = isnull(@e2, ''),
       cantE2 = SUM(   case
                           when FolioEstimacion = @e2 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE2 = SUM(   case
                          when FolioEstimacion = @e2 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE2 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c2 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE2 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c2 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE3 = isnull(@e3, ''),
       cantE3 = SUM(   case
                           when FolioEstimacion = @e3 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE3 = SUM(   case
                          when FolioEstimacion = @e3 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE3 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c3 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE3 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c3 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE4 = isnull(@e4, ''),
       cantE4 = SUM(   case
                           when FolioEstimacion = @e4 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE4 = SUM(   case
                          when FolioEstimacion = @e4 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE4 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c4 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE4 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c4 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE5 = isnull(@e5, ''),
       cantE5 = SUM(   case
                           when FolioEstimacion = @e5 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE5 = SUM(   case
                          when FolioEstimacion = @e5 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE5 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c5 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE5 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c5 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE6 = isnull(@e6, ''),
       cantE6 = SUM(   case
                           when FolioEstimacion = @e6 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE6 = SUM(   case
                          when FolioEstimacion = @e6 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE6 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c6 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE6 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c6 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE7 = isnull(@e7, ''),
       cantE7 = SUM(   case
                           when FolioEstimacion = @e7 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE7 = SUM(   case
                          when FolioEstimacion = @e7 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE7 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c7 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE7 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c7 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE8 = isnull(@e8, ''),
       cantE8 = SUM(   case
                           when FolioEstimacion = @e8 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE8 = SUM(   case
                          when FolioEstimacion = @e8 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE8 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c8 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE8 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c8 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE9 = isnull(@e9, ''),
       cantE9 = SUM(   case
                           when FolioEstimacion = @e9 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ),
       impE9 = SUM(   case
                          when FolioEstimacion = @e9 then
                              CantidadEstimacion
                          else
                              0
                      end
                  ) * PrecioUnitario,
       cantSE9 = CantidadOT - SUM(   case
                                         when Consecutivo <= @c9 then
                                             CantidadEstimacion
                                         else
                                             0
                                     end
                                 ),
       impSE9 = abs((CantidadOT - SUM(   case
                                             when Consecutivo <= @c9 then
                                                 CantidadEstimacion
                                             else
                                                 0
                                         end
                                     )
                    ) * PrecioUnitario
                   ),
       nE10 = isnull(@e10, ''),
       cantE10 = SUM(   case
                            when FolioEstimacion = @e10 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE10 = SUM(   case
                           when FolioEstimacion = @e10 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE10 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c10 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE10 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c10 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE11 = isnull(@e11, ''),
       cantE11 = SUM(   case
                            when FolioEstimacion = @e11 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE11 = SUM(   case
                           when FolioEstimacion = @e11 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE11 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c11 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE11 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c11 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE12 = isnull(@e12, ''),
       cantE12 = SUM(   case
                            when FolioEstimacion = @e12 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE12 = SUM(   case
                           when FolioEstimacion = @e12 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE12 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c12 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE12 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c12 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE13 = isnull(@e13, ''),
       cantE13 = SUM(   case
                            when FolioEstimacion = @e13 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE13 = SUM(   case
                           when FolioEstimacion = @e13 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE13 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c13 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE13 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c13 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE14 = isnull(@e14, ''),
       cantE14 = SUM(   case
                            when FolioEstimacion = @e14 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE14 = SUM(   case
                           when FolioEstimacion = @e14 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE14 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c14 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE14 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c14 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE15 = isnull(@e15, ''),
       cantE15 = SUM(   case
                            when FolioEstimacion = @e15 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE15 = SUM(   case
                           when FolioEstimacion = @e15 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE15 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c15 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE15 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c15 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE16 = isnull(@e16, ''),
       cantE16 = SUM(   case
                            when FolioEstimacion = @e16 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE16 = SUM(   case
                           when FolioEstimacion = @e16 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE16 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c16 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE16 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c16 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE17 = isnull(@e17, ''),
       cantE17 = SUM(   case
                            when FolioEstimacion = @e17 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE17 = SUM(   case
                           when FolioEstimacion = @e17 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE17 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c17 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE17 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c17 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE18 = isnull(@e18, ''),
       cantE18 = SUM(   case
                            when FolioEstimacion = @e18 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE18 = SUM(   case
                           when FolioEstimacion = @e18 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE18 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c18 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE18 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c18 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE19 = isnull(@e19, ''),
       cantE19 = SUM(   case
                            when FolioEstimacion = @e19 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE19 = SUM(   case
                           when FolioEstimacion = @e19 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE19 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c19 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE19 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c19 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    ),
       nE20 = isnull(@e20, ''),
       cantE20 = SUM(   case
                            when FolioEstimacion = @e20 then
                                CantidadEstimacion
                            else
                                0
                        end
                    ),
       impE20 = SUM(   case
                           when FolioEstimacion = @e20 then
                               CantidadEstimacion
                           else
                               0
                       end
                   ) * PrecioUnitario,
       cantSE20 = CantidadOT - SUM(   case
                                          when Consecutivo <= @c20 then
                                              CantidadEstimacion
                                          else
                                              0
                                      end
                                  ),
       impSE20 = abs((CantidadOT - SUM(   case
                                              when Consecutivo <= @c20 then
                                                  CantidadEstimacion
                                              else
                                                  0
                                          end
                                      )
                     ) * PrecioUnitario
                    )
into #tmpControlFinancieroMat
FROM #tmpEstimaciones
group by COncepto,
         DescripcionMat,
         Unidad,
         CantidadOT,
         PrecioUnitario

SELECT @importeOT = SUM(importe)
FROM #tmpControlFinancieroMat

SELECT *
FROM
(
    SELECT *,
           CAST(Concepto AS VARCHAR) AS ConceptoStr
    FROM #tmpControlFinancieroMat
) AS T
    CROSS APPLY
(
    SELECT CASE
               WHEN CHARINDEX('-', T.ConceptoStr) > 0
                    AND ISNUMERIC(LEFT(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) - 1)) = 1 THEN
                   TRY_CAST(LEFT(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) - 1)AS INT)
               ELSE
                   NULL
           END AS Parte1,
           CASE
               WHEN CHARINDEX('-', T.ConceptoStr) > 0
                    AND ISNUMERIC(SUBSTRING(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) + 1, LEN(T.ConceptoStr))) = 1 THEN
                   TRY_CAST(SUBSTRING(T.ConceptoStr, CHARINDEX('-', T.ConceptoStr) + 1, LEN(T.ConceptoStr)) AS INT)
               ELSE
                   NULL
           END AS Parte2
) AS X
ORDER BY Parte1,
         Parte2

INSERT INTO #tmpAcumulados
(
    impE1,
    impSE1,
    afMenE1,
    afMenSE1,
    afAcumE1
)
SELECT null,
       null,
       null,
       null,
       null

/*************EST1**************************/
UPDATE #tmpAcumulados
SET impE1 =
    (
        SELECT SUM(t1.impE1) FROM #tmpControlFinancieroMat t1
    ),
    impSE1 =
    (
        SELECT SUM(t1.impSE1) FROM #tmpControlFinancieroMat t1
    ),
    afMenE1 =
    (
        SELECT SUM(t1.impE1) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE1 =
    (
        SELECT SUM(t1.impSE1) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE1 =
    (
        SELECT SUM(t1.impE1) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100
FROM #tmpAcumulados t1

/*****************EST2**************************/
UPDATE #tmpAcumulados
SET impE2 =
    (
        SELECT SUM(t1.impE2) FROM #tmpControlFinancieroMat t1
    ),
    impSE2 =
    (
        SELECT SUM(t1.impSE2) FROM #tmpControlFinancieroMat t1
    ),
    afMenE2 =
    (
        SELECT SUM(t1.impE2) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE2 =
    (
        SELECT SUM(t1.impSE2) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE2 = (
    (
        SELECT SUM(t1.impE2) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE1
               )
FROM #tmpAcumulados t1

/*************EST3**************************/
UPDATE #tmpAcumulados
SET impE3 =
    (
        SELECT SUM(t1.impE3) FROM #tmpControlFinancieroMat t1
    ),
    impSE3 =
    (
        SELECT SUM(t1.impSE3) FROM #tmpControlFinancieroMat t1
    ),
    afMenE3 =
    (
        SELECT SUM(t1.impE3) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE3 =
    (
        SELECT SUM(t1.impSE3) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE3 = (
    (
        SELECT SUM(t1.impE3) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE2
               )
FROM #tmpAcumulados t1

/*************EST4**************************/
UPDATE #tmpAcumulados
SET impE4 =
    (
        SELECT SUM(t1.impE4) FROM #tmpControlFinancieroMat t1
    ),
    impSE4 =
    (
        SELECT SUM(t1.impSE4) FROM #tmpControlFinancieroMat t1
    ),
    afMenE4 =
    (
        SELECT SUM(t1.impE4) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE4 =
    (
        SELECT SUM(t1.impSE4) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE4 = (
    (
        SELECT SUM(t1.impE4) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE3
               )
FROM #tmpAcumulados t1

/*************EST5**************************/
UPDATE #tmpAcumulados
SET impE5 =
    (
        SELECT SUM(t1.impE5) FROM #tmpControlFinancieroMat t1
    ),
    impSE5 =
    (
        SELECT SUM(t1.impSE5) FROM #tmpControlFinancieroMat t1
    ),
    afMenE5 =
    (
        SELECT SUM(t1.impE5) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE5 =
    (
        SELECT SUM(t1.impSE5) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE5 = (
    (
        SELECT SUM(t1.impE5) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE4
               )
FROM #tmpAcumulados t1

/*************EST6**************************/
UPDATE #tmpAcumulados
SET impE6 =
    (
        SELECT SUM(t1.impE6) FROM #tmpControlFinancieroMat t1
    ),
    impSE6 =
    (
        SELECT SUM(t1.impSE6) FROM #tmpControlFinancieroMat t1
    ),
    afMenE6 =
    (
        SELECT SUM(t1.impE6) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE6 =
    (
        SELECT SUM(t1.impSE6) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE6 = (
    (
        SELECT SUM(t1.impE6) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE5
               )
FROM #tmpAcumulados t1

/*************EST7**************************/
UPDATE #tmpAcumulados
SET impE7 =
    (
        SELECT SUM(t1.impE7) FROM #tmpControlFinancieroMat t1
    ),
    impSE7 =
    (
        SELECT SUM(t1.impSE7) FROM #tmpControlFinancieroMat t1
    ),
    afMenE7 =
    (
        SELECT SUM(t1.impE7) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE7 =
    (
        SELECT SUM(t1.impSE7) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE7 = (
    (
        SELECT SUM(t1.impE7) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE6
               )
FROM #tmpAcumulados t1

/*************EST8**************************/
UPDATE #tmpAcumulados
SET impE8 =
    (
        SELECT SUM(t1.impE8) FROM #tmpControlFinancieroMat t1
    ),
    impSE8 =
    (
        SELECT SUM(t1.impSE8) FROM #tmpControlFinancieroMat t1
    ),
    afMenE8 =
    (
        SELECT SUM(t1.impE8) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE8 =
    (
        SELECT SUM(t1.impSE8) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE8 = (
    (
        SELECT SUM(t1.impE8) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE7
               )
FROM #tmpAcumulados t1

/*************EST9**************************/
UPDATE #tmpAcumulados
SET impE9 =
    (
        SELECT SUM(t1.impE9) FROM #tmpControlFinancieroMat t1
    ),
    impSE9 =
    (
        SELECT SUM(t1.impSE9) FROM #tmpControlFinancieroMat t1
    ),
    afMenE9 =
    (
        SELECT SUM(t1.impE9) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE9 =
    (
        SELECT SUM(t1.impSE9) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE9 = (
    (
        SELECT SUM(t1.impE9) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE8
               )
FROM #tmpAcumulados t1

/*************EST10**************************/
UPDATE #tmpAcumulados
SET impE10 =
    (
        SELECT SUM(t1.impE10) FROM #tmpControlFinancieroMat t1
    ),
    impSE10 =
    (
        SELECT SUM(t1.impSE10) FROM #tmpControlFinancieroMat t1
    ),
    afMenE10 =
    (
        SELECT SUM(t1.impE10) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE10 =
    (
        SELECT SUM(t1.impSE10) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE10 = (
    (
        SELECT SUM(t1.impE10) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE9
                )
FROM #tmpAcumulados t1

/*************EST11**************************/
UPDATE #tmpAcumulados
SET impE11 =
    (
        SELECT SUM(t1.impE11) FROM #tmpControlFinancieroMat t1
    ),
    impSE11 =
    (
        SELECT SUM(t1.impSE11) FROM #tmpControlFinancieroMat t1
    ),
    afMenE11 =
    (
        SELECT SUM(t1.impE11) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE11 =
    (
        SELECT SUM(t1.impSE11) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE11 = (
    (
        SELECT SUM(t1.impE11) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE10
                )
FROM #tmpAcumulados t1

/*************EST12**************************/
UPDATE #tmpAcumulados
SET impE12 =
    (
        SELECT SUM(t1.impE12) FROM #tmpControlFinancieroMat t1
    ),
    impSE12 =
    (
        SELECT SUM(t1.impSE12) FROM #tmpControlFinancieroMat t1
    ),
    afMenE12 =
    (
        SELECT SUM(t1.impE12) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE12 =
    (
        SELECT SUM(t1.impSE12) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE12 = (
    (
        SELECT SUM(t1.impE12) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE11
                )
FROM #tmpAcumulados t1

/*************EST13**************************/
UPDATE #tmpAcumulados
SET impE13 =
    (
        SELECT SUM(t1.impE13) FROM #tmpControlFinancieroMat t1
    ),
    impSE13 =
    (
        SELECT SUM(t1.impSE13) FROM #tmpControlFinancieroMat t1
    ),
    afMenE13 =
    (
        SELECT SUM(t1.impE13) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE13 =
    (
        SELECT SUM(t1.impSE13) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE13 = (
    (
        SELECT SUM(t1.impE13) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE12
                )
FROM #tmpAcumulados t1

/*************EST14**************************/
UPDATE #tmpAcumulados
SET impE14 =
    (
        SELECT SUM(t1.impE14) FROM #tmpControlFinancieroMat t1
    ),
    impSE14 =
    (
        SELECT SUM(t1.impSE14) FROM #tmpControlFinancieroMat t1
    ),
    afMenE14 =
    (
        SELECT SUM(t1.impE14) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE14 =
    (
        SELECT SUM(t1.impSE14) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE14 = (
    (
        SELECT SUM(t1.impE14) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE13
                )
FROM #tmpAcumulados t1

/*************EST15**************************/
UPDATE #tmpAcumulados
SET impE15 =
    (
        SELECT SUM(t1.impE15) FROM #tmpControlFinancieroMat t1
    ),
    impSE15 =
    (
        SELECT SUM(t1.impSE15) FROM #tmpControlFinancieroMat t1
    ),
    afMenE15 =
    (
        SELECT SUM(t1.impE15) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE15 =
    (
        SELECT SUM(t1.impSE15) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE15 = (
    (
        SELECT SUM(t1.impE15) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE14
                )
FROM #tmpAcumulados t1

/*************EST16**************************/
UPDATE #tmpAcumulados
SET impE16 =
    (
        SELECT SUM(t1.impE16) FROM #tmpControlFinancieroMat t1
    ),
    impSE16 =
    (
        SELECT SUM(t1.impSE16) FROM #tmpControlFinancieroMat t1
    ),
    afMenE16 =
    (
        SELECT SUM(t1.impE16) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE16 =
    (
        SELECT SUM(t1.impSE16) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE16 = (
    (
        SELECT SUM(t1.impE16) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE15
                )
FROM #tmpAcumulados t1

/*************EST17**************************/
UPDATE #tmpAcumulados
SET impE17 =
    (
        SELECT SUM(t1.impE17) FROM #tmpControlFinancieroMat t1
    ),
    impSE17 =
    (
        SELECT SUM(t1.impSE17) FROM #tmpControlFinancieroMat t1
    ),
    afMenE17 =
    (
        SELECT SUM(t1.impE17) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afMenSE17 =
    (
        SELECT SUM(t1.impSE17) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100,
    afAcumE17 = (
    (
        SELECT SUM(t1.impE17) / @importeOT FROM #tmpControlFinancieroMat t1
    ) * 100 + afAcumE16
                )
FROM #tmpAcumulados t1

SELECT *
FROM #tmpAcumulados

END;