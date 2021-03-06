fix_cnpj <- function(cnpj_in) {

  temp <- stringr::str_replace_all(cnpj_in, stringr::fixed('.'), '')
  temp <- stringr::str_replace_all(temp, '/|-', '')

  cnpj_out <- as.numeric(temp)

  return(cnpj_out)
}


select_responsible_beverage <- function() {

  # be responsible! - only drink after 18:00
  hour_now <- as.numeric(format(Sys.time(), '%H'))

  day_beverages <- c('coffee', 'mate-gaucho', 'english tea')
  night_beverages <- c('Cuba Libre', 'Caipirinha', 'Pisco Sour',
                       'Mojito', 'Beer', 'Wine', 'Coco Loco',
                       'Cachaca Joao Barreiro')

  if (hour_now < 18) {
    my_beverage <- sample(day_beverages, 1)
  } else {
    my_beverage <- sample(night_beverages, 1)
  }

  return(my_beverage)
}
