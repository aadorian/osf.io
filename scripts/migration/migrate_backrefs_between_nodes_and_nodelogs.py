"""
This migration will add original_node and node associated with the log to nodelogs. It will then make
copies of each nodelog for the remaining nodes in the backref (registrations and forks),
changing the node to the current node.
"""

import sys
import logging
from modularodm import Q
from website.app import init_app
from website import models
from scripts import utils as script_utils
from framework.transactions.context import TokuTransaction

logger = logging.getLogger(__name__)


def lookup_node(node_id):
    """
    Retrieves original node on nodelog
    """
    return models.Node.find(Q('_id', 'eq', node_id))[0]


def main(dry=True):
    init_app(routes=False)
    node_logs = models.NodeLog.find(Q('original_node', 'eq', None))
    total_log_count = node_logs.count()
    count = 0
    errored_logs = []
    for log in node_logs:
        count += 1
        with TokuTransaction():
            original_node = lookup_node(log.params['node'])
            log.original_node = original_node
            log.node = lookup_node(log._backrefs['logged']['node']['logs'][0])
            if not dry:
                try:
                    log.save()
                    logger.info('{}/{} Log {} "original_node = {} and node = {}" added'.format(count, total_log_count, log._id, log.original_node._id, log.node._id))
                except KeyError as error:
                    logger.error('Could not migrate log due to error')
                    logger.exception(error)
                    errored_logs.append(log)

            errored_clones = []
            logger.warn('Cloning log {} for nodes in backrefs'.format(log._id))
            for node in log._backrefs['logged']['node']['logs'][1:]:
                clone = log.clone_node_log(node)
                clone.original_node = original_node
                try:
                    clone.save()
                    logger.info('Log {} cloned for node {}. New log is {}'.format(log._id, node, clone._id))
                except KeyError as error:
                    logger.error('Could not copy node log due to error')
                    logger.exception(error)
                    errored_clones.append([log, clone])


if __name__ == '__main__':

    dry_run = 'dry' in sys.argv
    if not dry_run:
        script_utils.add_file_logger(logger, __file__)
    main(dry=dry_run)
