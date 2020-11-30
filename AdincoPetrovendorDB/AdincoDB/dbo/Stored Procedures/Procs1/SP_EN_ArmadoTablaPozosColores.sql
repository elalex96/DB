-- =============================================
-- Author:		Marcos Garcia
-- Create date: 13-07-2020
-- Description:	Armado Tabla de Colores de Pozo
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoTablaPozosColores]
-- ============================================= 
--[dbo].[SP_EN_ArmadoTablaPozosColores] 3,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        SET LANGUAGE Spanish;
        --=============================================    
        IF OBJECT_ID('tempdb..#Temporal', 'U') IS NOT NULL
            DROP TABLE #Temporal;
        --
        IF OBJECT_ID('tempdb..#TemporalTD', 'U') IS NOT NULL
            DROP TABLE #TemporalTD;
        --=============================================   
        CREATE TABLE #Temporal
        (Id          INT IDENTITY(1, 1), 
         Descripcion NVARCHAR(MAX), 
         Color       NVARCHAR(MAX)
        );
        --
        CREATE TABLE #TemporalTD
        (Id     INT IDENTITY(1, 1), 
         HtmlTD NVARCHAR(MAX)
        );
        --=============================================  
        INSERT INTO #Temporal
        (Descripcion, 
         Color
        )
        EXEC dbo.SP_ENIColoresPozos 
             @IdContrato, 
             @IdUsuario;
        INSERT INTO #TemporalTD(HtmlTD)
               SELECT CASE
                          WHEN Color IS NULL
                          THEN '<tr>                                            
                                    <td style="width:50px"></td>
                                    <td style="width:10px"></td>
                                    <td>' + Descripcion + '</td>
                                </tr>
                                <tr style="height:2px"></tr>'
                          WHEN Color IS NOT NULL
                          THEN '<tr>                                            
									<td style="background-color:' + Color + '; width:50px"></td>
									<td style="width:10px"></td>
									<td>' + Descripcion + '</td>
								</tr>
								<tr style="height:2px"></tr>'
                      END
               FROM #Temporal
               ORDER BY Id ASC;
        --=============================================  
        DECLARE @StringInicio VARCHAR(MAX), @StringFinal VARCHAR(MAX), @StringTD VARCHAR(MAX);
        DECLARE @Count INT, @Rows INT= 1;
        --=============================================  
        SET @StringInicio = '<table border="0">';
        SET @StringFinal = ' </table>';
        --
        SET @Count =
        (
            SELECT COUNT(*)
            FROM #TemporalTD
        );
        --
        WHILE(@Rows <= @Count)
            BEGIN
                SET @StringTD = COALESCE(@StringTD, '', '') +
                (
                    SELECT STUFF(
                    (
                        SELECT DISTINCT 
                               '  ' + CONVERT(NVARCHAR(MAX), TIO.HtmlTD)
                        FROM #TemporalTD TIO
                        WHERE TIO.Id = TATLE.Id FOR XML PATH(''), TYPE
                    ).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 1, '')
                    FROM #TemporalTD TATLE
                    WHERE TATLE.Id = @Rows
                );
                SET @Rows = @Rows + 1;
            END;
        --=============================================  
        SELECT @StringInicio + @StringTD + @StringFinal AS HtmlArmado;
        -- =============================================
    END;