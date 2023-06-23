CREATE PROCEDURE [dbo].[SP_AP_ObtenerHTMLBanner]
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ListaBanner VARCHAR(1000) = '',
            @PaginasBanner1 VARCHAR(8000) = '',
            @PaginasBanner2 VARCHAR(8000) = '',
            @PaginasBanner3 VARCHAR(8000) = '',
            @PaginasBanner4 VARCHAR(8000) = '',
            @PaginasBanner5 VARCHAR(8000) = '',
            @PaginasBanner6 VARCHAR(8000) = '',
            @PaginasBanner7 VARCHAR(8000) = '',
            @PaginaBannerEncabezado VARCHAR(8000) = '',
            @PaginaBannerPie VARCHAR(8000) = '',
            @Anio VARCHAR(10),
            @Mes VARCHAR(10),
            @MesActual DATE = GETDATE();

    CREATE TABLE #FechasBanner
    (
        IdRow INT,
        Anio VARCHAR(10),
        Mes VARCHAR(10),
        Dia VARCHAR(10),
        Descripcion VARCHAR(1500),
        Division INT
    )

    INSERT INTO #FechasBanner
    (
        IdRow,
        Anio,
        Mes,
        Dia,
        Descripcion
    )
    SELECT ROW_NUMBER() OVER (ORDER BY [Dia] ASC) AS IdRow,
           CONVERT(VARCHAR(10), Anio) Anio,
           NombreMes AS Mes,
           CASE
               WHEN Dia < 10 THEN
                   CONCAT('0', CONVERT(VARCHAR(10), Dia))
               ELSE
                   CONVERT(VARCHAR(10), Dia)
           END AS Dia,
           LTRIM(RTRIM(Descripcion)) AS Descripcion
    FROM AP_Calendario (NOLOCK)
    WHERE MONTH(IdFecha) = MONTH(@MesActual)
          AND YEAR(IdFecha) = YEAR(@MesActual)
          AND ISNULL(LTRIM(RTRIM(Descripcion)), '') <> ''

    UPDATE #FechasBanner
    SET Division = CASE
                       WHEN IdRow <= 5 THEN
                           1
                       WHEN IdRow > 5
                            AND IdRow <= 10 THEN
                           2
                       WHEN IdRow > 10
                            AND IdRow <= 15 THEN
                           3
                       WHEN IdRow > 15
                            AND IdRow <= 20 THEN
                           4
                       WHEN IdRow > 20
                            AND IdRow <= 25 THEN
                           5
                       WHEN IdRow > 25
                            AND IdRow <= 30 THEN
                           6
                       ELSE
                           7
                   END

    IF ((SELECT TOP 1 COUNT(1) FROM #FechasBanner) > 0)
    BEGIN
        SELECT TOP 1
            @Anio = Anio,
            @Mes = Mes
        FROM #FechasBanner
        ORDER BY Division DESC

        SELECT @ListaBanner
            = STUFF(
              (
                  SELECT '<li data-target="#myCarousel" data-slide-to="' + CONVERT(VARCHAR(10), Division) + '"></li>'
                  FROM #FechasBanner
                  GROUP BY Division
                  FOR XML PATH('')
              ),
              1,
              0,
              ''
                   )


        SET @PaginaBannerEncabezado
            = +'<div class="item" style="align-items: center">
                        <div class="container">
                            <div class="row" style="display: flex; justify-content: center; width: 100%; height: 100%; margin: 0;">
                                <table style="align-self: center">
                                    <tbody>
                                        <tr>
                                            <th style="width: 200px; text-align: center; font-size: 30px; color: #004987; font-style: normal; font-family: Arial; padding: 10px"><b>'
              + @Anio
              + '</b>
                                                <br />
                                                <b>' + LTRIM(RTRIM(UPPER(@Mes)))
              + '</b></th>
                                            <th></th>
                                            <th style="width: 10px; text-align: center; font-size: 18px; color: black; font-style: normal; font-family: Arial; padding: 10px">E<br />
                                                V<br />
                                                E<br />
                                                N<br />
                                                T<br />
                                                O<br />
                                                S </th>
                                            <th></th>
                                            <th style="width: 600px; padding: 10px; text-align: left;">
                                                <ul>';
        SET @PaginaBannerPie
            = +'</ul>
                                            </th>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>';

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 1) > 0)
        BEGIN
            SET @PaginasBanner1
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 1
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 2) > 0)
        BEGIN
            SET @PaginasBanner2
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 2
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 3) > 0)
        BEGIN
            SET @PaginasBanner3
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 3
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END


        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 4) > 0)
        BEGIN
            SET @PaginasBanner4
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 4
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 5) > 0)
        BEGIN
            SET @PaginasBanner5
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 5
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 6) > 0)
        BEGIN
            SET @PaginasBanner6
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 6
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        IF ((SELECT COUNT(1) FROM #FechasBanner WHERE Division = 7) > 0)
        BEGIN
            SET @PaginasBanner7
                = @PaginaBannerEncabezado
                  + STUFF(
                    (
                        SELECT '<li><b style="font-size: 15px; color: black; font-style: initial; font-family: Arial;">'
                               + Dia + '</b> - ' + Descripcion + '</li>'
                        FROM #FechasBanner
                        WHERE Division = 7
                        ORDER BY IdRow ASC
                        FOR XML PATH('')
                    ),
                    1,
                    0,
                    ''
                         ) + @PaginaBannerPie;
        END

        SET @ListaBanner = REPLACE(REPLACE(@ListaBanner, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner1 = REPLACE(REPLACE(@PaginasBanner1, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner2 = REPLACE(REPLACE(@PaginasBanner2, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner3 = REPLACE(REPLACE(@PaginasBanner3, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner4 = REPLACE(REPLACE(@PaginasBanner4, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner5 = REPLACE(REPLACE(@PaginasBanner5, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner6 = REPLACE(REPLACE(@PaginasBanner6, '&lt;', '<'), '&gt;', '>');
        SET @PaginasBanner7 = REPLACE(REPLACE(@PaginasBanner7, '&lt;', '<'), '&gt;', '>');

    END;

    SELECT ' <div class="col-md-12">
        <div class="dashboard-box dashboard-box-chart bg-white content-box">
            <div id="myCarousel" class="carousel slide" data-ride="carousel">              
                <ol class="carousel-indicators">
                    <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
					' + @ListaBanner
           + '
                </ol>
                <div class="carousel-inner">
                    <div class="item active">
                        <img src="ContactoAdinco.png" alt="ContactoAdinco">
                    </div>
					' + @PaginasBanner1 + @PaginasBanner2 + @PaginasBanner3 + @PaginasBanner4 + @PaginasBanner5
           + @PaginasBanner6 + @PaginasBanner7
           + '
                </div>            
                <a class="left carousel-control" href="#myCarousel" data-slide="prev">
                    <span class="glyphicon glyphicon-chevron-left"></span>
                    <span class="sr-only">Previous</span>
                </a>
                <a class="right carousel-control" href="#myCarousel" data-slide="next">
                    <span class="glyphicon glyphicon-chevron-right"></span>
                    <span class="sr-only">Next</span>
                </a>
            </div>
        </div>
    </div>' AS 'HTML';
END